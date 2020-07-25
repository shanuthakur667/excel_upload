class User < ApplicationRecord
  validates :first_name, :last_name, :email_id, presence: true
  validates :email_id, format: { with: /.+@.+\..+/i }

  class << self
    def open_spreadsheet(file)
      case File.extname(file.original_filename)
      when ".csv" then
        Roo::CSV.new(file.path, file_warning: :ignore)
      when ".xlsx" then
        Roo::Excelx.new(file.path, packed: false, file_warning: :ignore)
      else
        raise "Unknown file type: #{file.original_filename}"
      end
    end

    def generate_data(data)
      begin
        error_message = ""
        save_count = 0
        data.each_with_index do |row, i|
          user = self.find_or_initialize_by(email_id: row['EMAIL_ID'])
          user.attributes = {first_name: row['FIRST_NAME'], last_name: row['LAST_NAME']}
          unless user.save
            error_message += "<li>\nrow#{i}:"
            error_message += user.try(:errors).try(:full_messages).join(',')
            error_message += "</li>"
          else
            save_count += 1
          end
        end
        error_message += "\n<li> Total Data in csv: #{data.count}</li>"
        error_message += "\n<li> Total data saved from csv: #{save_count}</li>"
        error_message += "\n<li> Error count from csv: #{(data.count - save_count)}</li>"
        error_message
      rescue Exception => ex
        Rails.logger.info "-- Exception occured in import users due to #{ex.message} ----- "
      end
    end
  end
end
