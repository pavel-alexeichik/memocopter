class CardsSetsController < ApplicationController
  before_action :set_cards_set, only: [:show, :edit, :update, :destroy]

  # GET /cards_sets
  # GET /cards_sets.json
  def index
    @cards_sets = CardsSet.all
  end

  # GET /cards_sets/1
  # GET /cards_sets/1.json
  def show
  end

  # GET /cards_sets/new
  def new
    @cards_set = CardsSet.new
  end

  # GET /cards_sets/1/edit
  def edit
  end

  # POST /cards_sets
  # POST /cards_sets.json
  def create
    @cards_set = CardsSet.new(cards_set_params)

    respond_to do |format|
      if @cards_set.save
        format.html { redirect_to @cards_set, notice: 'Cards set was successfully created.' }
        format.json { render :show, status: :created, location: @cards_set }
      else
        format.html { render :new }
        format.json { render json: @cards_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cards_sets/1
  # PATCH/PUT /cards_sets/1.json
  def update
    respond_to do |format|
      if @cards_set.update(cards_set_params)
        format.html { redirect_to @cards_set, notice: 'Cards set was successfully updated.' }
        format.json { render :show, status: :ok, location: @cards_set }
      else
        format.html { render :edit }
        format.json { render json: @cards_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cards_sets/1
  # DELETE /cards_sets/1.json
  def destroy
    @cards_set.destroy
    respond_to do |format|
      format.html { redirect_to cards_sets_url, notice: 'Cards set was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cards_set
      @cards_set = CardsSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cards_set_params
      params.require(:cards_set).permit(:user_id, :name)
    end
end
