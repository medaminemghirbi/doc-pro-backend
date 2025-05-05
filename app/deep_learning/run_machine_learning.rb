# app/services/run_machine_learning.rb
class RunMachineLearning
  def self.call(image_path)
    script_path = Rails.root.join('app', 'deep_learning', 'predict.py')

    # Command to run the Python script with the image path as an argument
    command = "python3 #{script_path} #{image_path}"

    # Execute the command
    output = `#{command}`

    # Check if the script ran successfully
    if $?.exitstatus == 0
      Rails.logger.info "Machine Learning executed successfully."
      Rails.logger.info "Output: #{output}"
      
      return output
    else
      Rails.logger.error "Machine Learning failed."
      Rails.logger.error "Output: #{output}"

      return nil
    end
  end
end
