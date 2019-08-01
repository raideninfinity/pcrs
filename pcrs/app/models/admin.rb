class Admin < ApplicationRecord
	def auth_password(pw)
		md5 = Digest::MD5.new           
		md5.update(self.name)
		md5 << pw
		pass = md5.hexdigest	
		if self.password.length < 32 && pw == self.password
			self.password = pass
			self.save
		end
		return (pass == self.password)
	end
end

