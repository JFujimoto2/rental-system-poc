module ApplicationHelper
  def aging_class(days)
    if days > 90
      "aging-critical"
    elsif days > 60
      "aging-danger"
    elsif days > 30
      "aging-warning"
    else
      "aging-normal"
    end
  end
end
