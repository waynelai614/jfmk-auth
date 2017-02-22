# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
                                       key: '_jfmk_auth_session',
                                       expire_after: ApplicationController::SESSION_EXPIRES_AFTER_SECONDS
