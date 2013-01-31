class Directory
  
  def self.crawl(path)
    require 'json'

    json = JSON.parse(File.read(path));
    json.each_with_index do |section, index|
      unless section["Term"].nil?
        puts "(" << (index+1).to_s << " of " << json.length << "): " << section["Course"];
        Section.update_or_create(section);
      end
    end
  end
end
