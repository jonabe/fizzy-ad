Fizzy::Saas::Engine.routes.draw do
  Queenbee.routes(self)

  namespace :admin do
    mount Audits1984::Engine, at: "/console"
  end
end
