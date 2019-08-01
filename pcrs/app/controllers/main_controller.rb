class MainController < ApplicationController

  helper_method :back, :get_code_name, :auth_code_owner, :check_purchase_conditions, :get_current_user_credits, :auth_reload_owner, :admin_ip?

  def index
    @page = params[:page].to_i
    @page ||= 1
    @page = 1 if @page < 1
    @result_limit = 9
    params[:search] ||= {}
    @search_type = params[:search][:type].to_i
    @search_value = params[:search][:value]
    @search_type ||= 0
    @search_value ||= ""
    @list = get_list
    @count = @search_value != "" ? @list[0].count : PrepaidType.count
    if params[:purchase] || params[:purchase].to_i > 0
       purchase_id = params[:purchase].to_i
      if !logged_in?
        params[:err1] = true
      elsif !@list[1][purchase_id] || @list[1][purchase_id] == 0
        params[:err2] = true
      elsif current_user.credits < (PrepaidType.find(purchase_id).price * 100)
        params[:err3] = true
      else
        redirect_to controller: 'main', action: 'purchase', id: purchase_id
      end
    end    
  end
  
  def back
    redirect_to '/'
  end
  
  def get_list
    if @search_value == ""
      arr1 = PrepaidType.limit(@result_limit).offset((@page - 1) * @result_limit)
    else
      if @search_type == 0
        str = "#{@search_value}%"
      elsif @search_type == 1
        str = "%#{@search_value}%"
      else
        str = "#{@search_value}%"
      end
      arr1 = PrepaidType.where("name LIKE ?" , str).limit(@result_limit).offset((@page - 1) * @result_limit)
    end    
    str = '
    select prepaid_type_id, count(prepaid_type_id) 
    from prepaid_codes where id not in (
      select c.id 
      from prepaid_codes c, prepaid_purchases p
      where c.id = p.prepaid_code_id
    )  
    group by prepaid_type_id
    '
    arr2 = sql(str).rows.to_h
    return [arr1,arr2]
  end
  
  def login
    user = User.find_by(name: params[:login][:name].downcase)
    if user && user.auth_password(params[:login][:password])
      log_in user
      log_user "LOG_IN", "AUTH_SUCCESS"
      redirect_to controller: 'main', action: 'index'
    else
      log_user "LOG_IN", "AUTH_FAILURE", user if user
      redirect_to controller: 'main', action: 'index', login_error: true
    end
  end
  
  def logout
    log_out
    redirect_to '/'   
  end
  
  def edit_details
    if params[:edit_password]
      edit_password
    elsif params[:edit_email]
      edit_email
    elsif params[:edit_dob]
      edit_dob
    end
  end
  
  def edit_password
      opw = params[:edit_password][:opw]
      npw1 = params[:edit_password][:npw1]
      npw2 = params[:edit_password][:npw2]
      params[:edit_password] = nil
      params[:type] = "1"
      return params[:err1] = true if (!current_user.auth_password(opw))
      validate_pw = validate_str(npw1) && (npw1.length >= 6) && (npw1 == npw2)
      return params[:err2] = true if !validate_pw
      current_user.password = npw1
      current_user.save
      current_user.auth_password(npw1)
      log_user "CHANGE_PASSWORD", "SUCCESS"
      return params[:success] = true
  end
  
  def edit_email
    opw = params[:edit_email][:opw]
    email = params[:edit_email][:email]
    params[:edit_email] = nil
    params[:type] = "2"     
    return params[:err1] = true if (!current_user.auth_password(opw))
    return params[:err2] = true if !validate_email(email)
    old_email = current_user.email
    current_user.email = email
    current_user.save
    log_user "CHANGE_EMAIL", "FROM #{old_email} TO #{email}"
    return params[:success] = true
  end
  
  def edit_dob
    opw = params[:edit_dob][:opw]
    day = params[:edit_dob][:day].to_i
    month = get_month(params[:edit_dob][:month])
    year = params[:edit_dob][:year].to_i
    params[:edit_dob] = nil
    params[:type] = "3"     
    return params[:err1] = true if (!current_user.auth_password(opw))
    return params[:err2] = true if !check_dob(day, month, year)
    old_dob = current_user.dob
    current_user.dob = Date.new(year,month,day)   
    current_user.save    
    log_user "CHANGE_DOB", "FROM #{old_dob} TO #{current_user.dob}"
    return params[:success] = true    
  end
  
  def view_codes
    @page = params[:page].to_i
    @page ||= 1
    @page = 1 if @page < 1
    @result_limit = 25
    @list = get_code_list
    @count = @list[1]
  end
  
  def get_code_list
    arr1 = PrepaidPurchase.where("user_id = ?", current_user.id).limit(@result_limit).offset((@page - 1) * @result_limit)
    count = PrepaidPurchase.count("user_id = #{current_user.id}")
    return [arr1,count]
  end
  
  def get_code_name(code)
    pid = code.prepaid_code_id
    pcode = PrepaidCode.find(pid)
    return PrepaidType.find(pcode.prepaid_type_id).name
  end
  
  def auth_code_owner(id)
    return current_user.id == PrepaidPurchase.find(id).user_id
  end
  
  def purchase
    if params[:purchase]
      id = params[:purchase][:purchase_id].to_i
      if !check_purchase_conditions(id)
        params[:purchase] = nil 
        return
      end
      params[:purchase_result] = true
      begin
        type = PrepaidType.find(id)
        item = PrepaidCode.where('
        prepaid_type_id = ? and id not in (
        select c.id 
        from prepaid_codes c, prepaid_purchases p
        where c.id = p.prepaid_code_id
        )
        ',id).first
        purchase = PrepaidPurchase.new
        purchase.user_id = current_user.id
        purchase.prepaid_code_id = item.id
        purchase.purchase_price = type.price
        purchase.save
        current_user.credits -= type.price * 100
        current_user.save
        params[:success] = true
        params[:code] = item.code
        params[:pin] = item.pin
        str = "(#{type.name}, #{type.price}, #{type.image_id}), #{item.code},
                #{(!item.pin || item.pin.empty?) ? "-" : item.pin}"     
        log_user "PURCHASE_CODE", str
      rescue
        params[:err1] = true
      end
    end
  end
  
  def check_purchase_conditions(id)
    return false if !id || id == 0 || !logged_in?
    type = PrepaidType.find(id)
    str = "
    select id 
    from prepaid_codes where prepaid_type_id = #{id} and id not in (
      select c.id 
      from prepaid_codes c, prepaid_purchases p
      where c.id = p.prepaid_code_id
    )  
    group by prepaid_type_id
    "
    count = sql(str).rows.flatten.flatten[0]
    return false if !count || count == 0
    return false if (type.price * 100) > current_user.credits
    return true
  end
  
  def reload
    @page = params[:page].to_i
    @page ||= 1
    @page = 1 if @page < 1
    @result_limit = 25
    @list = get_reload_list
    @count = @list[1]
    @p_count = get_pending_count
    
    if params[:reload_request]
      submit_reload_request
    end
  end
  
  def get_reload_list
    arr1 = ReloadRequest.where("user_id = ?", current_user.id).limit(@result_limit).offset((@page - 1) * @result_limit)
    count = ReloadRequest.count("user_id = #{current_user.id}")
    return [arr1,count]
  end
  
  def get_pending_count
    return ReloadRequest.count("user_id = #{current_user.id} and approved = 'PENDING'")
  end
  
  def get_current_user_credits
    i = current_user.credits
    return i.to_s + sprintf(" (RM %.2f)",i / 100.0)
  end
  
  def auth_reload_owner(id)
    return current_user.id == ReloadRequest.find(id).user_id
  end
  
  def submit_reload_request
    tid = params[:reload_request][:tid]
    ttype = params[:reload_request][:ttype]
    comments = params[:reload_request][:comments]  
    return params[:err1] = true if tid.empty? || ttype.empty?
    begin
      req = ReloadRequest.new
      req.user_id = current_user.id
      req.transaction_id = tid
      req.transaction_type = ttype
      req.comments = comments
      req.approved = "PENDING"
      str = "#{tid}, #{ttype}, #{comments}"
      req.save
      log_user "REQUEST_RELOAD", str
    rescue
      return params[:err2] = true
    end
    return params[:success] = true
  end
  
end
