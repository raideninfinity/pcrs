Rails.application.routes.draw do
  root 'main#index' #homepage of the website
  post '/', to: 'main#index' #root of the website
  #main controller
  get 'main/index'
  post 'main/index'
  post 'main/login', to: 'main#login'
  post 'main/logout', to: 'main#logout' 
  get 'main/edit_details', to: 'main#edit_details'
  post 'main/edit_details', to: 'main#edit_details'  
  get 'main/view_codes', to: 'main#view_codes'
  post 'main/view_codes', to: 'main#view_codes' 
  get 'main/purchase', to: 'main#purchase'
  post 'main/purchase', to: 'main#purchase' 
  get 'main/reload', to: 'main#reload'
  post 'main/reload', to: 'main#reload'  
  #register controller
  get 'register/index', to: 'register#index'
  post 'register/index', to: 'register#index'  
  #admin controller
  get 'admin/index', to: 'admin#index'
  post 'admin/index', to: 'admin#index'
  get 'admin/login', to: 'admin#login'
  post 'admin/login', to: 'admin#login'
  get 'admin/logout', to: 'admin#logout'
  post 'admin/logout', to: 'admin#logout' 
  get 'admin/manage_prepaid_types', to: 'admin#manage_prepaid_types'
  post 'admin/manage_prepaid_types', to: 'admin#manage_prepaid_types'  
  get 'admin/manage_prepaid_codes', to: 'admin#manage_prepaid_codes'
  post 'admin/manage_prepaid_codes', to: 'admin#manage_prepaid_codes'  
  get 'admin/manage_reloads', to: 'admin#manage_reloads'
  post 'admin/manage_reloads', to: 'admin#manage_reloads'  
  get 'admin/manage_users', to: 'admin#manage_users'
  post 'admin/manage_users', to: 'admin#manage_users'  
  get 'admin/view_logs', to: 'admin#view_logs'
  post 'admin/view_logs', to: 'admin#view_logs'
end
