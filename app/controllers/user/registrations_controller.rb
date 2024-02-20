# frozen_string_literal: true

class User::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  def create
    # Verifica se a empresa já existe pelo parâmetro enviado
    company = Company.find_or_create_by(name: params[:user][:company])
    
    # Se a empresa não existir, cria uma nova
    if company.new_record?
      # Lógica para criar uma nova empresa, se necessário
    end
    
    # Atribui a empresa ao parâmetro do usuário antes de criar o usuário
    params[:user][:company_id] = company.id
    
    super
  end

  private

  # Define os parâmetros permitidos
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :company_id)
  end

  protected


  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:company_id])
  end
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
