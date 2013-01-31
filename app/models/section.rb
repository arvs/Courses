class Section < ActiveRecord::Base
  belongs_to :course
  belongs_to :instructor
  belongs_to :department
  belongs_to :subject

  def self.update_or_create( info )
    # initialize section by section key
    section = Section.find_or_create_by_section_key(info["Term"] + info["Course"])

    # only update section if it has not been touch in the last 12 hours
    # return section unless section.call_number.nil?

    # section number
    section.section_number = info["Course"][-3..-2]

    #title
    section.title = info["CourseTitle"]
      
    # subject
    section.subject = Subject.find_or_create_by_title_and_abbreviation(info["PrefixName"], info["Course"][0,4])

    #meta
    section.url = "http://www.columbia.edu/cu/bulletin/uwb/subj/" + info["Course"][0,4] + "/" + info["Course"][8] + info["Course"][4,4] + "-" + info["Term"] + "-" + info["Course"][-3..-1] + "/"
    section.semester = info["Term"]
    section.description = info["ClassNotes"]
    section.instructor = Instructor.find_or_create_by_name(info["Instructor1Name"])
    section.department = Department.find_or_create_by_title_and_abbreviation(info["DepartmentName"], info["DepartmentCode"])
    section.call_number = info["CallNumber"]

    #Need more info about json syntax to update
    =begin
      section.days = info[:days]
      section.start_time = info[:start_time]
      section.end_time = info[:end_time]
      section.room = info[:room]
      section.building = info[:building]
    =end

    # enrollment
    section.enrollment = info["NumEnrolled"]
    section.max_enrollment = info["MaxSize"]

    # course
    section.course = Course.update_or_create(info)

    section.save!
  end
end
