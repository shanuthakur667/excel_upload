class UsersController < ApplicationController
  def upload_csv
    spreadsheet = eval(controller_path.classify).open_spreadsheet(params[:file]) if params[:file].present?
    if !params[:file].present? || (spreadsheet.last_row).to_i < 2
      notice_msg = "Empty file not accepted!!!"
    else
      header = spreadsheet.row(1)
      if header.map(&:to_s).sort.compact == (controller_path.classify.upcase + "_HEADER").constantize.sort
        if spreadsheet.last_row < 12
          data_arr = Array.new
          (2..spreadsheet.last_row).each do |row_i|
            data_arr << Hash[[header, spreadsheet.row(row_i)].transpose]
          end
          error_message = eval(controller_path.classify).generate_data(data_arr)
          notice_msg = error_message.blank? ? "CSV is uploded" : error_message
        else
          notice_msg = "Data more then 10 not accepted!!!"
        end
      else
        notice_msg = "Please put valid csv file"
      end
    end
    redirect_to index_routes, notice: notice_msg
  end

  def sample_csv
    request.format = 'csv'
    csv_data = CSV.generate(headers: true) do |csv|
      csv << (controller_path.classify.upcase + "_HEADER").constantize
      csv << (controller_path.classify.upcase + "_ROW").constantize
    end
    if request.get?
      respond_to do |format|
        format.csv do
          file_name  = (controller_path + ".csv")
          send_data csv_data,
            :filename => file_name,
            :type =>  "text/csv; charset=utf-8; header=present"
        end
      end
    end
  end
end
