require 'rails_helper'

describe League::Division do
  before(:all) { create(:league_division) }

  it { should belong_to(:league) }

  it { should have_many(:rosters).class_name('Roster') }
  it { should have_many(:matches).class_name('Match').through(:rosters).source(:home_team_matches) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }
end
