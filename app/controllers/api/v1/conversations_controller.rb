class Api::V1::ConversationsController < ApiController

  before_action :get_app
  before_action :get_user_data
  before_action :authorize!

  def show
    @user = get_app_user
    @conversation = user_conversations.find(params[:id])
    # TODO paginate here
    @messages = @conversation.messages
    render :show
  end

  def index
    # TODO: paginate here
    @user = get_app_user
    @conversations = @app.conversations.where(main_participant: @user.id)
    render :index
  end

  def create
    #@user = find_user(get_user_data["email"])    
    user = get_app_user

    if params[:message].present?
      @conversation = @app.start_conversation({
        message: params[:message], 
        from: user
      })
    else
      # return a conversation with empty messages , if any or create new one
      # this is to avoid multiple empty convos
      @conversation = user.conversations
                          .left_joins(:messages)
                          .where(conversation_parts: {id: nil})
                          .uniq
                          .first || @app.conversations.create(main_participant: user)
    end
    render :show
  end

  def update
    @user = get_app_user
    @conversation = user_conversations.find(params[:id])

    @message = @conversation.add_message({
      from: @user,
      message: params[:message]
    })
    render :show
  end

private

  def get_app
    @app = App.find_by(key: params[:app_id])
  end

  def user_conversations
    @app.conversations.where(main_participant: @user.id)
  end
end
