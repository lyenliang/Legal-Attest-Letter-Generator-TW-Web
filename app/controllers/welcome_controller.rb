require 'securerandom'

class WelcomeController < ApplicationController

	def generate_pdf
		@name = generate_file_name

		senderName = params[:senderName].gsub(/[^\p{Alnum}]/,'')
		senderAddr = params[:senderAddr].gsub(/[^\p{Alnum}]/,'')
		receiverName = params[:receiverName].gsub(/[^\p{Alnum}]/,'')
		receiverAddr = params[:receiverAddr].gsub(/[^\p{Alnum}]/,'')
		ccName = params[:ccName].gsub(/[^\p{Alnum}]/,'')
		ccAddr = params[:ccAddr].gsub(/[^\p{Alnum}]/,'')

		# write text into a file
		path = "public/download/#{@name}.txt"
		innerText = params[:innerText]
		File.open(path, "w+") do |f|
		  @fresult = f.write(innerText)
		end

		command = "python3 tw-lal-generator.py ../#{path}"

		if senderName != ''
			command << " --senderName #{senderName}"
		end
		if senderAddr != ''
			command << " --senderAddr #{senderAddr}"
		end
		if receiverName != ''
			command << " --receiverName #{receiverName}"
		end
		if receiverAddr != ''
			command << " --receiverAddr #{receiverAddr}"
		end
		if ccName != ''
			command << " --ccName #{ccName}"
		end
		if ccAddr != ''
			command << " --ccAddr #{ccAddr}"
		end

		@result = %x(cd python ; #{command} --outputFileName ../public/download/#{@name}.pdf 2>&1)

		send_file( Rails.root.join('public/download', "#{@name}.pdf"), type: 'application/pdf')
	end
	
	private 
	
	def generate_file_name
		t = Time.zone.now
		return "lal_" << t.year.to_s \
					  << "%02d" % t.month.to_s \
					  << "_" \
					  << "%02d" % t.hour.to_s \
					  << "%02d" % t.min.to_s \
					  << "%02d" % t.sec.to_s
	end

end
