module RouteHelper
  def self.create_helper(action_name, class_name)
    case action_name
    when :index, :create
      define_method("#{class_name}_path") do
        "/#{class_name}"
      end
    when :new
      define_method("new_#{class_name.chop}_path") do
        "/#{class_name}/new"
      end
    when :update, :destroy, :show
      define_method("#{class_name.chop}_path") do |id|
        "/#{class_name}/#{id}"
      end
    when :edit
      define_method("edit_#{class_name.chop}_path") do |id|
        "/#{class_name}/#{id}/edit"
      end
    else
      raise "Not a valid action name"
    end
  end
end