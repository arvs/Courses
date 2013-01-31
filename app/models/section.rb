class Section < ActiveRecord::Base
  belongs_to :course
  belongs_to :instructor
  belongs_to :department
  belongs_to :subject

  def self.update_or_create( hash_data )
    require 'open-uri'

    begin
      doc = Nokogiri::HTML(open( url ))
    rescue
      puts "Bad section url"
      return
    end

    html = doc.to_html.gsub(/<\/?[^>]*>/, " ")

    # initialize section by section key
    section = Section.find_or_create_by_section_key( hash_data[:section_key] )

    # only update section if it has not been touch in the last 12 hours
    # return section unless section.call_number.nil?

    # section number
    section.section_number = hash_data[:section_number]

    #title
    section.title = hash_data[:title]
      
    # subject
    section.subject = Subject.find_or_create_by_abbreviation( hash_data[:subject_id] )

    #meta
    section.url = hash_data[:url]
    section.semester = hash_data[:semester]
    section.description = hash_data[:description]

    section.instructor = Instructor.find_or_create_by_name( hash_data[:instructor_id] )

    if html =~ /Department/
      section.department = Department.find_or_create_by_title( hash_data[:department_id] )
    end

    if html =~ /Call Number/
      section.call_number = hash_data[:call_number]
    end

    if html =~ /Day \&amp; Time Location/
      section.days = hash_data[:days]

      section.start_time = hash_data[:start_time]
      section.end_time = hash_data[:end_time]
      
      #Needs to be changed to check file for TBA
      if match[4].strip != "To be announced" 
        section.room = hash_data[:room]
        section.building = hash_data[:building]
      end
    end

    if html =~ /[0-9]+ students \([0-9]+ max/
      section.enrollment = hash_data[:enrollment]
      section.max_enrollment = hash_data[:max_enrollment]
    end

    # course
    if html =~ /\n\s*Number\s*\n/
      section.course = Course.update_or_create( hash_data[:course_id] )
    end

    section.save!
  end
end
