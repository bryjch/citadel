require 'rails_helper'

describe Leagues::Rosters::TransfersController do
  let(:user) { create(:user) }
  let(:player) { create(:user) }
  let(:bencher) { create(:user) }
  let(:roster) { create(:league_roster) }

  before do
    roster.team.add_player!(bencher)
    roster.team.add_player!(player)
    roster.add_player!(player, approved: true)
  end

  describe 'GET #show' do
    it 'succeeds for authorized captain' do
      user.grant(:edit, roster.team)
      sign_in user

      get :show, params: { league_id: roster.league.id, roster_id: roster.id }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for authorized admin' do
      user.grant(:edit, roster.league)
      sign_in user

      get :show, params: { league_id: roster.league.id, roster_id: roster.id }

      expect(response).to have_http_status(:success)
    end

    it 'redirects for authorized captain when rosters are locked' do
      user.grant(:edit, roster.team)
      roster.league.update!(roster_locked: true)
      sign_in user

      get :show, params: { league_id: roster.league.id, roster_id: roster.id }

      expect(response).to redirect_to(league_roster_path(roster.league, roster))
    end

    it 'redirects for unauthorized user' do
      sign_in user

      get :show, params: { league_id: roster.league.id, roster_id: roster.id }

      expect(response).to redirect_to(league_roster_path(roster.league, roster))
    end
  end

  describe 'POST #create' do
    it 'succeeds for authorized captain with bencher no auto-approve' do
      user.grant(:edit, roster.team)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        transfer: { user_id: bencher.id, is_joining: true }
      }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.pending_transfer?(bencher)).to be(true)
    end

    it 'succeeds for authorized captain with bencher auto-approved' do
      user.grant(:edit, roster.team)
      roster.league.update!(transfers_require_approval: false)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        transfer: { user_id: bencher.id, is_joining: true }
      }

      expect(roster.on_roster?(bencher)).to be(true)
      expect(roster.league.pending_transfer?(bencher)).to be(false)
    end

    it 'fails if rosters are locked' do
      user.grant(:edit, roster.team)
      roster.league.update!(roster_locked: true)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        transfer: { user_id: bencher.id, is_joining: true }
      }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.pending_transfer?(bencher)).to be(false)
    end

    it 'fails transferring bencher out for authorized captain' do
      user.grant(:edit, roster.team)
      sign_in user

      post :create, params: {
        league_id: roster.league.id, roster_id: roster.id,
        transfer: { user_id: bencher.id, is_joining: false }
      }

      expect(roster.on_roster?(bencher)).to be(false)
      expect(roster.league.pending_transfer?(bencher)).to be(false)
    end

    # TODO: player tests, as opposed to bencher
  end
end
