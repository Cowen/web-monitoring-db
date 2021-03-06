Rails.application.routes.draw do
  root 'home#index'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  devise_scope :user do
    get 'users/session', to: 'users/sessions#validate_session'
  end

  namespace :api do
    namespace :v0 do
      resources :pages, only: [:index, :show], format: :json do
        resources :versions, only: [:index, :show, :create] do
          resources :annotations, only: [:index, :show, :create]
        end

        resources :annotations,
          path: 'changes/:from_uuid..:to_uuid/annotations',
          from_uuid: /[^.\/]*/, # allow :from_uuid to be an empty string
          only: [:index, :show, :create]

        member do
          get 'changes/:from_uuid..:to_uuid/diff/:type',
            to: 'diff#show',
            from_uuid: /[^.\/]*/ # allow :from_uuid to be an empty string
        end
      end

      resources :versions, only: [:index, :show], format: :json
      resources :imports, only: [:create, :show], format: :json
    end
  end

  get 'admin', to: 'admin#index'
  post 'admin/invite'
  get 'admin/invite', to: redirect('admin')
  delete 'admin/cancel_invitation'
  post 'admin/cancel_invitation'
  delete 'admin/destroy_user'
  post 'admin/destroy_user'
end
