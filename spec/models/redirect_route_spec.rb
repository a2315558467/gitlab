require 'rails_helper'

describe RedirectRoute, models: true do
  let(:group) { create(:group) }
  let!(:redirect_route) { group.redirect_routes.create(path: 'gitlabb') }

  describe 'relationships' do
    it { is_expected.to belong_to(:source) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_presence_of(:path) }
    it { is_expected.to validate_uniqueness_of(:path) }
  end

  describe '.matching_path_and_descendants' do
    let!(:redirect2) { group.redirect_routes.create(path: 'gitlabb/test') }
    let!(:redirect3) { group.redirect_routes.create(path: 'gitlabb/test/foo') }
    let!(:redirect4) { group.redirect_routes.create(path: 'gitlabb/test/foo/bar') }
    let!(:redirect5) { group.redirect_routes.create(path: 'gitlabb/test/baz') }

    it 'returns correct routes' do
      expect(RedirectRoute.matching_path_and_descendants('gitlabb/test')).to match_array([redirect2, redirect3, redirect4, redirect5])
    end
  end
end
