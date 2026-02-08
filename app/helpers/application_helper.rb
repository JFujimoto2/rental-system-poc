module ApplicationHelper
  def approvable_summary(approvable)
    case approvable
    when Contract
      "#{approvable.room&.building&.name} #{approvable.room&.room_number} — #{approvable.tenant&.name}"
    when Construction
      "#{approvable.room&.building&.name} #{approvable.room&.room_number} — #{approvable.title}"
    else
      approvable.to_s
    end
  end

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
