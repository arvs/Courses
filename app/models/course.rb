class Course < ActiveRecord::Base
  has_many :sections

  define_index do
    # fields
    indexes title
    indexes description
    indexes course_key
    indexes sections.title, :as => :section_titles
    indexes sections.description, :as => :section_descriptions
    indexes sections.department.title, :as => :department
    indexes sections.subject.title, :as => :subject

    has sections.semester, :as => :semesters
    has sections.instructor.name, :as => :instructors
    has sections.building, :as => :buildings
    has sections.days, :as => :days
    has sections.start_time, :as => :start_times
    has sections.end_time, :as => :end_times

    set_property :field_weights => {
      :course_key => 10,
      :title => 5,
      :section_titles => 2
    }
  end

  def self.update_or_create(info)
    course = Course.find_or_create_by_course_key(info["CallNumber"])
    return course unless course.title.nil?

    puts course_key + ": loading course data"

    # title
    course.title = info["CourseTitle"]

    # description
    course.description = info["ClassNotes"]

    # points
    course.points = info["NumFixedUnites"].to_f / 10

    course.save!
    return course
  end
end
