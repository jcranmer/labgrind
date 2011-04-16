# A calendar event.
# This simply respresents some kind of event that people want to make note
# of, that runs for a specific period of time. It can be marked as exclusive,
# meaning the lab can be reserved for that period of time, and (TODO) it can
# also be tied to a specific project.
class Event < ActiveRecord::Base
  belongs_to :lab

  # Checks to see if, at any point, this event is running concurrently with
  # another event.
  def overlaps? other
    not (end_time < other.start_time or start_time > other.end_time)
  end

  # Checks to see if this event conflicts with another event.
  # Two events conflict if they run at the same time, in the same lab, and if
  # at least one of them is exclusive.
  def conflicts_with? other
    lab == other.lab and overlaps? other and (exclusive or other.exclusive)
  end
end
