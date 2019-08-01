class RegisterController < ApplicationController

  def index
    if params[:register]
      perform_register(params[:register])
    end  
  end
  
  def perform_register(data)
    name = data[:name]
    pw1 = data[:pw1]
    pw2 = data[:pw2]
    day = data[:day].to_i
    month = get_month(data[:month])
    year = data[:year].to_i
    email = data[:email]   
    params[:err1] = true if !((validate_str(name) && name.length >= 4 && name.length <= 64 &&
      name[0].to_i.to_s != name[0])) || User.exists?(name: name)
    params[:err2] = true if !((validate_str(pw1) && pw1.length >= 6) && (pw1 == pw2))
    params[:err3] = true if !Date.valid_date?(year, month, day)
    params[:err4] = true if !validate_email(email)   
    params[:success] = true & !params[:err1] & !params[:err2] & !params[:err3] & !params[:err4]  
    if params[:success]
      begin
        user = User.new
        user.name = name
        user.password = pw1
        user.dob = Date.new(year,month,day)
        user.email = email
        user.credits = 0  
        user.save
        user.auth_password(pw1)
        str = "#{user.name}, #{user.dob}, #{user.email}"
        log_user "REGISTER", str, user
      rescue
        params[:success] = false
        params[:err5] = true
      end
    end 
  end  

end


