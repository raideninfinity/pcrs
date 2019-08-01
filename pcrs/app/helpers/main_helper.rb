module MainHelper

  def admin_ip?
    ip = request.remote_ip.to_s
    ip = "127.0.0.1" if ip == "::1"
    return AdminIp.exists?(ip: ip.to_s)
  end  
  
  def log_in(user)
    session[:user_id] = user.id
  end
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  def log_out
    session.delete(:user_id)
    @current_user = nil  
  end
  
  def admin_log_in(admin)
	session[:admin_id] = admin.id
  end
  
  def current_admin
    @current_admin ||= Admin.find_by(id: session[:admin_id])
  end
  
  def admin_logged_in?
    !current_admin.nil?
  end
  
  def admin_log_out
    session.delete(:admin_id)
    @current_admin = nil  
  end
  
	def check_dob(day, month, year)
		check_leap_year = (year % 4 == 0)
		check_leap_year &= !(year % 100 == 0)
		check_leap_year |= (year % 400 == 0)
		return true if check_leap_year && day == 29 && month == 2
    return false if (month == 2 && day >= 30)
    return false if (day == 31 && [4,6,9,11].include?(month))
		return true
	end
	
	def get_month(month)	
    return 0 if month == "-"
		return {"Jan" => 1, "Feb" => 2, "Mar" => 3, "Apr" => 4,
			  "May" => 5, "Jun" => 6, "Jul" => 7, "Aug" => 8, 
			  "Sep" => 9, "Oct" => 10, "Nov" => 11, "Dec" => 12}[month]	  
	end

	def validate_str(string)
		!string.match(/\A[a-zA-Z0-9]*\z/).nil?
	end

	def validate_num(string)
		!string.match(/\A[0-9]*\z/).nil?
	end
	
	def validate_email(string)
		string =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	end
  
  def log_admin(name,details,admin = nil)
    begin
      item = AdminLog.new
      ip = request.remote_ip.to_s
      ip = "127.0.0.1" if ip == "::1"
      item.ip = ip
      item.admin_id = admin ? admin.id : current_admin.id
      item.action_name = name.upcase
      item.action_details = details
      item.save
    rescue
    end
  end
  
  def log_user(name,details, user = nil)
    begin
      item = UserLog.new
      ip = request.remote_ip.to_s
      ip = "127.0.0.1" if ip == "::1"
      item.ip = ip
      item.user_id = user ? user.id : current_user.id
      item.action_name = name.upcase
      item.action_details = details
      item.save
    rescue
    end  
  end
  
end
