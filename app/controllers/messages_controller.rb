class MessagesController < ApplicationController
    def index
        if current_user
            @messages = Message.all.paginate(page: params[:page], per_page: 20).order('create_date DESC')
        else
            redirect_to splash_path
        end
    end

    def edit
        if current_user
            @message = Message.find(params[:message_id])
            render :edit
        else
            redirect_to splash_path
        end
    end

    def copy
        @org = Org.first
        @message = Message.find params[:message_id]
        copy_message = Message.new do |m|
            m.title = @message.title + ' copy'
            m.message_text = @message.message_text
            m.text_message = @message.text_message
            m.org_id = @org.id
            m.create_date = Date.today
        end
        copy_message.save
        redirect_to messages_path
    end

    def new
        if current_user
            @message = Message.new
            @org = Org.first
            render :new
        else
            redirect_to splash_path
        end
    end

    def create
        @message = Message.create(message_params)
        redirect_to messages_path
    end

    def update
        message_sent = Messhistory.where(message_id: params[:message_id]).exists?
        if message_sent
            flash[:notice] = 'Messages cannot be changed if they have been sent'
        else
            @message = Message.find params[:message_id]
            @message.update(message_params)
            flash[:notice] = 'Message updated'
        end
        redirect_to messages_path
    end

    def send_message
        @message = Message.find params[:message_id]
        # this is a solution for a single org. this can be expanded when other organizations can create messages
        main_org = Org.find_by org_name: 'General'
        # get all users

        UserOrg.where(org_id: main_org.id).find_each do |user|
            sponsoring_user = User.find user.user_id
            # for each user, get all of their targets
            # I use a join here to get user data and target data. The user data can be used to create the message to the user - functionality to be added
            request_origin = 'bulk send'
            Target.select('users.*, targets.*').joins(:user).where(targets: { user_id: user.user_id }).find_each do |target|
                if target.status == 'Active'
                    create_single_message(sponsoring_user, target, @message, request_origin)
                end
            end
        end
        # create 1 record that the message was sent. This is part of the message history

        mess = Messhistory.new do |m|
            m.sent_date = Date.today
            m.message_id = @message.id
            m.org_id = @message.org_id
        end
        mess.save
        redirect_to messages_path
    end

    def make_hot_message
        @message = Message.find params[:message_id]
        # this is a solution for a single org. this can be expanded when other organizations can create messages
        main_org = Org.find_by org_name: 'General'
        # get all users

        # create 1 record that the message was sent. This is part of the message history

        mess = Messhistory.new do |m|
            m.sent_date = Date.today
            m.message_id = @message.id
            m.org_id = @message.org_id
        end
        mess.save
        redirect_to messages_path
    end


    def destroy
        @message = Message.find params[:message_id]
        message_sent = Messhistory.where(message_id: params[:message_id]).exists?
        if message_sent
            flash[:notice] = 'Messages cannot be changed if they have been sent'
        else
            @message.destroy
            flash[:notice] = 'Message deleted'
        end
        redirect_to messages_path
    end

      private

    def message_params
        params.require(:message).permit(:title, :message_text, :text_message, :create_date, :org_id)
    end

end
