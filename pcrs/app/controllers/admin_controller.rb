class AdminController < ApplicationController

  helper_method :admin_ip?, :back, :admin?, :get_prepaid_type_stock,  :format_prepaid_type_string, :get_stock_prepaid_code_count, :trim, :get_log_xls_data
  
  def admin?
    admin_logged_in?
  end
  
  def back
    redirect_to '/'
  end

  def login
    return if !params[:login]
    admin = Admin.find_by(name: params[:login][:name].downcase)
    if admin && admin.auth_password(params[:login][:password])
      admin_log_in admin
      log_admin "LOG_IN", "AUTH_SUCCESS"
      redirect_to controller: 'admin', action: 'index'
    else
      log_admin "LOG_IN", "AUTH_FAILURE", admin if admin
      redirect_to controller: 'admin', action: 'login', login_error: true
    end  
  end
  
  def logout
    admin_log_out
    redirect_to '/'   
  end
  
  def index
    respond_to do |format|
      format.html
      format.xls
    end 
  end
  
  def init_page(func)
    @page = params[:page].to_i
    @page ||= 1
    @page = 1 if @page < 1
    @result_limit = 25
    @list = method(func).call
    @count = @list[1]
  end
  
  def manage_prepaid_types
    init_page(:get_prepaid_type_list)
    perform_prepaid_type_delete if params[:f_delete]
    perform_prepaid_type_add if params[:f_add]
    perform_prepaid_type_edit if params[:f_edit]
    if params[:edit]
      begin
        @item = PrepaidType.find(params[:edit])
      rescue
        @item = PrepaidType.new
      end
    end
  end
  
  def get_prepaid_type_list
    arr1 = PrepaidType.all.limit(@result_limit).offset((@page - 1) * @result_limit)
    count = PrepaidType.count
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
    return [arr1,count,arr2]
  end
  
  def perform_prepaid_type_delete
    begin
      id = params[:f_delete][:id].to_s
      item = PrepaidType.find(id)
      str = "#{item.name}, #{item.price}, #{item.image_id}"
      item.delete
      params[:result] = 100
      log_admin "PREPAID_TYPE_DELETE", str
    rescue
      params[:result] = 102
    end
  end
  
  def perform_prepaid_type_add
    name = params[:f_add][:name]
    price = params[:f_add][:price].to_f
    image = params[:f_add][:image].to_i
    if name == "" || price <= 0 || image < 0
      params[:result] = 101
    else  
      begin
        item = PrepaidType.new
        item.name = name
        item.price = price
        item.image_id = image
        str = "#{item.name}, #{item.price}, #{item.image_id}"
        item.save
        params[:result] = 100
        log_admin "PREPAID_TYPE_ADD", str    
      rescue
        params[:result] = 102
      end
    end
    params[:add] = "true" if params[:result] != 100
  end
  
  def perform_prepaid_type_edit
    id = params[:f_edit][:id].to_i
    name = params[:f_edit][:name]
    price = params[:f_edit][:price].to_f
    image = params[:f_edit][:image].to_i
    if name == "" || price <= 0 || image < 0
      params[:result] = 101
    else  
      begin
        item = PrepaidType.find(id)
        str1 = "#{item.name}, #{item.price}, #{item.image_id}"
        item.name = name
        item.price = price
        item.image_id = image
        str2 = "#{item.name}, #{item.price}, #{item.image_id}"
        item.save
        params[:result] = 100
        log_admin "PREPAID_TYPE_EDIT", "FROM #{str1} TO #{str2}"
      rescue
        params[:result] = 102
      end
    end
    params[:edit] = id if params[:result] != 100
  end
  
  def manage_prepaid_codes
    @show_all = params[:show_all] == "true"
    init_page(:get_prepaid_code_list)
    perform_prepaid_code_delete if params[:f_delete]
    perform_prepaid_code_add if params[:f_add]
    perform_prepaid_code_edit if params[:f_edit]
    if params[:edit]
      begin
        @item = PrepaidCode.find(params[:edit])
      rescue
        @item = PrepaidCode.new
      end
    end
    setup_prepaid_type_options if params[:add] || params[:edit]    
  end
  
  def get_stock_prepaid_code_count(b = false)
    str = '
    select id, prepaid_type_id
    from prepaid_codes where id not in (
      select c.id 
      from prepaid_codes c, prepaid_purchases p
      where c.id = p.prepaid_code_id
    )  
    '
    arr2 = sql(str).rows.to_h
    return b ? arr2 : arr2.count
  end
  
  def get_prepaid_code_list
    if !@show_all
      str = 'id not in (
      select c.id 
      from prepaid_codes c, prepaid_purchases p
      where c.id = p.prepaid_code_id
      )'
      arr1 = PrepaidCode.where(str).limit(@result_limit).offset((@page - 1) * @result_limit)
    else
      arr1 = PrepaidCode.all.limit(@result_limit).offset((@page - 1) * @result_limit)
    end  
    arr2 = get_stock_prepaid_code_count(true)
    @scount = arr2.count
    @ccount = PrepaidCode.count
    count = (!@show_all) ? @scount : @ccount
    return [arr1,count,arr2]
  end
  
  def trim(str, count)
    if str.length > count
      str = str[0..count - 3]
      str << "..."
    end 
    return str
  end
  
  def format_prepaid_type_string(id)
    @ptype ||= {}
    return @ptype[id] if @ptype[id]
    item = PrepaidType.find(id)
    name = item.name
    trim(name, 24)
    str = "#{id} - #{name} (RM #{sprintf("%.2f",item.price)})"
    return @ptype[id] = str
  end
  
  def perform_prepaid_code_delete
    begin
      id = params[:f_delete][:id].to_s
      item = PrepaidCode.find(id)
      type = PrepaidType.find(item.prepaid_type_id)
      str = "(#{type.name}, #{type.price}, #{type.image_id}), #{item.code}, #{(!item.pin || item.pin.empty?) ? "-" : item.pin}"
      item.delete
      params[:result] = 100
      log_admin "PREPAID_CODE_DELETE", str
    rescue
      params[:result] = 102
    end
  end
  
  def perform_prepaid_code_add
    code = params[:f_add][:code]
    pin = params[:f_add][:pin]
    type = params[:f_add][:type].to_i
    if code == ""
      params[:result] = 101
    else  
      begin
        item = PrepaidCode.new
        item.code = code
        item.pin = pin
        item.prepaid_type_id = type
        item.admin_id = current_admin.id
        type = PrepaidType.find(item.prepaid_type_id)
        str = "(#{type.name}, #{type.price}, #{type.image_id}), #{item.code}, #{(!item.pin || item.pin.empty?) ? "-" : item.pin}"        
        item.save
        params[:result] = 100
        log_admin "PREPAID_CODE_ADD", str
      rescue
        params[:result] = 102
      end
    end
    params[:add] = "true" if params[:result] != 100
  end
  
  def perform_prepaid_code_edit
    id = params[:f_edit][:id].to_i
    code = params[:f_edit][:code]
    pin = params[:f_edit][:pin]
    type = params[:f_edit][:type].to_i
    if code == ""
      params[:result] = 101
    else  
      begin
        item = PrepaidCode.find(id)
        ptype = PrepaidType.find(item.prepaid_type_id)
        str1 = "(#{ptype.name}, #{ptype.price}, #{ptype.image_id}), #{item.code}, #{(!item.pin || item.pin.empty?) ? "-" : item.pin}"   
        item.code = code
        item.pin = pin
        item.prepaid_type_id = type
        item.admin_id = current_admin.id
        ptype = PrepaidType.find(item.prepaid_type_id)
        str2 = "(#{ptype.name}, #{ptype.price}, #{ptype.image_id}), #{item.code}, #{(!item.pin || item.pin.empty?) ? "-" : item.pin}"   
        item.save
        params[:result] = 100
        log_admin "PREPAID_CODE_EDIT", "FROM #{str1} TO #{str2}"
      rescue
        params[:result] = 102
      end
    end
    params[:edit] = id if params[:result] != 100
  end
  
  def setup_prepaid_type_options
    list = PrepaidType.all
    arr = []
    list.each do |item|
      id = item.id
      str = format_prepaid_type_string(id)
      arr.push [str,id]
    end
    @prepaid_type_arr = arr
  end
  
  def manage_reloads
    @show_all = params[:show_all] == "true"
    init_page(:get_reload_request_list)
    perform_reload_process if params[:f_process]
  end
  
  def get_reload_request_list
    str = "approved = 'PENDING'"
    if !@show_all
      arr1 = ReloadRequest.where(str).limit(@result_limit).offset((@page - 1) * @result_limit)
    else
      arr1 = ReloadRequest.all.limit(@result_limit).offset((@page - 1) * @result_limit)
    end  
    @scount = ReloadRequest.where(str).count
    @ccount = ReloadRequest.count
    count = !@show_all ? @scount : @ccount
    return [arr1,count]    
  end
  
  def perform_reload_process
    id = params[:f_process][:id].to_i
    result = params[:f_process][:result]
    credits = params[:f_process][:credits].to_i
    comments = params[:f_process][:comments]
    if credits <= 0 && result == "APPROVED"
      params[:result] = 101
    else  
      begin
        item = ReloadRequest.find(id)
        item.approved = result
        item.admin_id = current_admin.id
        item.approve_comments = comments
        item.approve_time = Time.now
        if result == "APPROVED" 
          item.approve_credits = credits
          user = User.find(item.user_id)
          user.credits += credits
          user.save
        else
          item.approve_credits = 0
        end
        str = "#{item.approved}, #{item.approve_credits}, #{item.approve_comments}"
        item.save
        params[:result] = 100
        log_admin "RELOAD_PROCESS", str
      rescue
        params[:result] = 102
      end
    end
    params[:process] = id if params[:result] != 100    
  end
  
  def manage_users
    init_page(:get_user_list)
    perform_user_delete if params[:f_delete]
    perform_user_edit if params[:f_edit]
    if params[:edit]
      begin
        @item = User.find(params[:edit])
      rescue
        @item = User.new
      end
    end  
  end
  
  def get_user_list
    arr1 = User.all.limit(@result_limit).offset((@page - 1) * @result_limit)
    count = User.count
    return [arr1, count]  
  end
  
  def perform_user_delete
    begin
      id = params[:f_delete][:id].to_s
      item = User.find(id)
      str = "#{item.name}, #{item.dob}, #{item.email}, #{item.credits}"
      item.delete
      params[:result] = 100
      log_admin "USER_DELETE", str
    rescue
      params[:result] = 102
    end
  end
  
  def perform_user_edit
    id = params[:f_edit][:id]
    name = params[:f_edit][:name]
    pw1 = params[:f_edit][:pw1]
    pw2 = params[:f_edit][:pw2]
    edit_pw = (pw1.length > 0)
    day = params[:f_edit][:day].to_i
    month = params[:f_edit][:month].to_i
    year = params[:f_edit][:year].to_i
    email = params[:f_edit][:email]
    credits = params[:f_edit][:credits].to_i
    
    error = false
    error = true if !((validate_str(name) && name.length >= 4 && name[0].to_i.to_s != name[0]))
    if edit_pw
      error = true if !((validate_str(pw1) && pw1.length >= 4) && (pw1 == pw2))
    end  
    error = true if !Date.valid_date?(year,month,day)
    error = true if !validate_email(email)
    error = true if credits < 0
    
    if (!error)
      begin
        item = User.find(id)
        str1 = "#{item.name}, #{item.dob}, #{item.email}, #{item.credits}"
        item.name = name
        item.dob = Date.new(year,month,day)
        item.email = email
        item.credits = credits
        str2 = "#{item.name}, #{item.dob}, #{item.email}, #{item.credits}"
        item.save
        if edit_pw
          item.password = pw1 
          item.auth_password(pw1)
        end
        params[:result] = 100
        str3 = edit_pw ? " WITH PASSWORD CHANGE" : ""
        log_admin "USER_EDIT", "FROM #{str1} TO #{str2}#{str3}"
      rescue
        params[:result] = 102
      end
    else
      params[:result] = 101
    end
    params[:edit] = id if params[:result] != 100  
  end
  
  def view_logs
    params[:log_type] ||= 0
    @day ||= "-"
    @month ||= "-"
    @year ||= "-"
    if params[:f_filter]
      f = params[:f_filter]
      @day = f[:day]
      @month = f[:month]
      @year = f[:year]
    end
    @log_type = params[:log_type].to_i
    case @log_type
      when 1; init_page(:get_purchase_log)
      when 2; init_page(:get_user_log)
      when 3; init_page(:get_admin_log)
    end
  end
  
  def get_filter_condition
    str = ""
    year = @year.to_i
    str += "YEAR(created_at) = #{year} " if year > 0      
    month = get_month(@month)
    str += "AND "if !str.empty? && month > 0  
    str += "MONTH(created_at) = #{month.to_i} " if month > 0   
    day = @day.to_i   
    str += "AND "if !str.empty? && day > 0  
    str += "DAY(created_at) = #{day.to_i} " if day > 0  
    return str
  end
  
  def get_purchase_log
    str = get_filter_condition
    arr1 = PrepaidPurchase.where(str).limit(@result_limit).offset((@page - 1) * @result_limit)
    count = PrepaidPurchase.where(str).count
    @total_sales = PrepaidPurchase.where(str).sum('purchase_price')
    return [arr1,count]
  end
  
  def get_user_log
    str = get_filter_condition
    arr1 = UserLog.where(str).limit(@result_limit).offset((@page - 1) * @result_limit)
    count = UserLog.where(str).count
    return [arr1,count]
  end

  def get_admin_log
    str = get_filter_condition
    arr1 = AdminLog.where(str).limit(@result_limit).offset((@page - 1) * @result_limit)
    count = AdminLog.where(str).count
    return [arr1,count]
  end
  
  def get_log_xls_data
    @log_type = params[:log_type].to_i
    return [] if ![1,2,3].include?(@log_type)
    @day = params[:day].to_i
    @month = params[:month]
    @year = params[:year].to_i
    model = [PrepaidPurchase, UserLog, AdminLog][@log_type - 1]
    return model.where(get_filter_condition)
  end
  
end
