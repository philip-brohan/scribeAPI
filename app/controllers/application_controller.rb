class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  # Get a User instance - either the currently logged-in user or a new Guest user
  def require_user!
    current_or_guest_user(create_if_missing = true)
  end

  # Get currently logged-in user, creating guest as indicated
  def current_or_guest_user(create_if_missing = false)
    if current_user
      # Previous guest user? Convert to user:
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        guest_user_logging_in
        guest_user(create_if_missing = false).try(:destroy)
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user create_if_missing
    end
  end

  # Find guest_user object associated with the current session
  def guest_user(create_if_missing = true)
    session[:guest_user_id] ||= User.create_guest_user.id if create_if_missing
    @cached_guest_user ||= User.find(session[:guest_user_id]) if ! session[:guest_user_id].nil?
    if @cached_guest_user.nil? && create_if_missing
      session[:guest_user_id] = (@cached_guest_user = User.create_guest_user).id
    end
    @cached_guest_user
  end

  private

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def guest_user_logging_in
    puts "convert guest user to reg user"
    # For example:
    # guest_comments = guest_user.comments.all
    # guest_comments.each do |comment|
      # comment.user_id = current_user.id
      # comment.save!
    # end
  end



  def parse_pagination
    @page = get_int :page, 1
    @per_page = get_int :per_page, 20, (1..100)
  end

  # Parse integer out of GET
  # Returns given default if nil or if fails given range
  def get_int(key, default=nil, range=nil)
    return default if params[key].nil? || params[key].class != String
    return default if ! (/^\d+$/ === params[key])
    val = params[key].to_i
    return default if ! range.nil? && ! range.include?(val)
    val
  end

  # Parse (validate) objectid out of GET
  # Returns nil if absent/invalid
  def get_objectid(key)
    return nil if params[key].nil? || ! params[key].is_a?(String)
    return nil if params[key].size != 24 || ! (/^\w+$/ === params[key])
    params[key]
  end

  # Parse bool out of GET
  def get_bool(key, default=nil)
    return default if params[key].nil? || params[key].class != String
    return true if (/^(1|true|t|on|yes)$/ === params[key])
    return false if (/^(0|false|f|off|no|)$/ === params[key])
    return default
  end

end
