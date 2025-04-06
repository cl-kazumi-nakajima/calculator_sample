class CalculatorController < ApplicationController
  def index
    @display = session[:display] || "0"
    @operation = session[:operation]
    @first_number = session[:first_number]
  end

  def append
    # Get the current display value from the session
    current = session[:display] || "0"
    
    # Get the value to append from the params
    value = params[:value]
    
    # Check if we're ready to enter the second number
    if session[:ready_for_second_number]
      # Start with a new number for the second operand
      new_value = value
      # Reset the flag
      session[:ready_for_second_number] = false
    else
      # Handle special case for decimal point
      if value == "."
        # If the display already has a decimal point, don't add another one
        if current.include?(".")
          new_value = current
        else
          new_value = current + value
        end
      else
        # If the display is just "0", replace it with the new value
        # Otherwise, append the new value
        new_value = (current == "0") ? value : current + value
      end
    end
    
    # Update the session
    session[:display] = new_value
    
    respond_to do |format|
      format.turbo_stream
    end
  end

  def operation
    # Store the current display value as the first number
    session[:first_number] = session[:display].to_f
    
    # Store the operation
    session[:operation] = params[:op]
    
    # Set a flag to indicate we're ready for the second number
    session[:ready_for_second_number] = true
    
    # Keep displaying the first number instead of resetting to "0"
    # session[:display] = "0"
    
    respond_to do |format|
      format.turbo_stream
    end
  end

  def calculate
    # Get the first number and the operation from the session
    first_number = session[:first_number].to_f
    operation = session[:operation]
    
    # Get the second number from the current display
    second_number = session[:display].to_f
    
    # Perform the calculation
    result = case operation
    when "+"
      first_number + second_number
    when "-"
      first_number - second_number
    when "*"
      first_number * second_number
    when "/"
      # Handle division by zero
      second_number.zero? ? "Error" : first_number / second_number
    else
      second_number
    end
    
    # Format the result to avoid unnecessary decimal places
    result = result.to_s
    result = result.end_with?(".0") ? result.to_i.to_s : result
    
    # Update the session
    session[:display] = result
    session[:first_number] = nil
    session[:operation] = nil
    session[:ready_for_second_number] = false
    
    respond_to do |format|
      format.turbo_stream
    end
  end

  def clear
    # Reset all session variables
    session[:display] = "0"
    session[:first_number] = nil
    session[:operation] = nil
    session[:ready_for_second_number] = false
    
    respond_to do |format|
      format.turbo_stream
    end
  end
end
