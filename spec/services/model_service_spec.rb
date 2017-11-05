require 'rails_helper'

RSpec.describe ModelService, type: :model do
  describe '.to_h' do
    before do
      @genre_documentary = FactoryBot.create(:genre, name: 'Documentary')

      @broadcaster_bbc = FactoryBot.create(:broadcaster, name: 'BBC')

      @programme_planet_earth = FactoryBot.create(:programme, name: 'Planet Earth', broadcaster: @broadcaster_bbc, genre: @genre_documentary)
      @programme_blue_planet = FactoryBot.create(:programme, name: 'Blue Planet', broadcaster: @broadcaster_bbc, genre: @genre_documentary)

      @star_david_attenborough = FactoryBot.create(:star, name: 'David Attenborough', gender: 'Male')

      FactoryBot.create(:contract, programme: @programme_planet_earth, star: @star_david_attenborough)
      FactoryBot.create(:contract, programme: @programme_blue_planet, star: @star_david_attenborough)

      @genre_tv_series = FactoryBot.create(:genre, name: 'TV Series')

      @programme_sherlock_s1 = FactoryBot.create(:programme, name: 'Sherlock S1', broadcaster: @broadcaster_bbc, genre: @genre_tv_series)
      @programme_sherlock_s2 = FactoryBot.create(:programme, name: 'Sherlock S2', broadcaster: @broadcaster_bbc, genre: @genre_tv_series)
      @programme_sherlock_s3 = FactoryBot.create(:programme, name: 'Sherlock S3', broadcaster: @broadcaster_bbc, genre: @genre_tv_series)
      @programme_sherlock_s4 = FactoryBot.create(:programme, name: 'Sherlock S4', broadcaster: @broadcaster_bbc, genre: @genre_tv_series)

      @star_benedict_cumberbatch = FactoryBot.create(:star, name: 'Benedict Cumberbatch', gender: 'Male')
      @star_martin_freeman = FactoryBot.create(:star, name: 'Martin Freeman', gender: 'Male')
      @star_amanda_abbington = FactoryBot.create(:star, name: 'Amanda Abbington', gender: 'Female')

      FactoryBot.create(:contract, programme: @programme_sherlock_s1, star: @star_benedict_cumberbatch)
      FactoryBot.create(:contract, programme: @programme_sherlock_s1, star: @star_martin_freeman)
      FactoryBot.create(:contract, programme: @programme_sherlock_s1, star: @star_amanda_abbington)
      FactoryBot.create(:contract, programme: @programme_sherlock_s2, star: @star_benedict_cumberbatch)
      FactoryBot.create(:contract, programme: @programme_sherlock_s2, star: @star_martin_freeman)
      FactoryBot.create(:contract, programme: @programme_sherlock_s1, star: @star_amanda_abbington)
      FactoryBot.create(:contract, programme: @programme_sherlock_s3, star: @star_benedict_cumberbatch)
      FactoryBot.create(:contract, programme: @programme_sherlock_s3, star: @star_martin_freeman)
      FactoryBot.create(:contract, programme: @programme_sherlock_s1, star: @star_amanda_abbington)
      FactoryBot.create(:contract, programme: @programme_sherlock_s4, star: @star_benedict_cumberbatch)
      FactoryBot.create(:contract, programme: @programme_sherlock_s4, star: @star_martin_freeman)
      FactoryBot.create(:contract, programme: @programme_sherlock_s1, star: @star_amanda_abbington)
    end

    context 'without condition' do
      it 'should return array of hashes' do
        expect(ModelService.to_h(
          table: Star,
          columns: [:id, :name, :gender],
        )).to match_array (
          [
            {id: @star_david_attenborough.id, name: @star_david_attenborough.name, gender: @star_david_attenborough.gender},
            {id: @star_benedict_cumberbatch.id, name: @star_benedict_cumberbatch.name, gender: @star_benedict_cumberbatch.gender},
            {id: @star_martin_freeman.id, name: @star_martin_freeman.name, gender: @star_martin_freeman.gender},
            {id: @star_amanda_abbington.id, name: @star_amanda_abbington.name, gender: @star_amanda_abbington.gender},
          ]
        )
      end
    end

    context 'with simple condition' do
      context 'with matches' do
        it 'should return array of hashes' do
          expect(ModelService.to_h(
            table: Star.where(gender: 'Female'),
            columns: [:id, :name, :gender],
          )).to match_array (
            [
              {id: @star_amanda_abbington.id, name: @star_amanda_abbington.name, gender: @star_amanda_abbington.gender},
            ]
          )
        end
      end

      context 'without matches' do
        it 'should return array of hashes' do
          expect(ModelService.to_h(
            table: Star.where(name: 'Michael Bay'),
            columns: [:id, :name, :gender],
          )).to match_array ([])
        end
      end
    end

    context 'with joins' do
      it 'should return array of hashes' do
        expect(ModelService.to_h(
          table: Programme.joins(:genre).joins(:broadcaster),
          columns: ['programmes.id', :name, 'genres.name', 'broadcasters.name'],
        )).to match_array (
          [
            {'programmes.id' => @programme_planet_earth.id, name: @programme_planet_earth.name, 'genres.name' => @programme_planet_earth.genre.name, 'broadcasters.name' => @programme_planet_earth.broadcaster.name},
            {'programmes.id' => @programme_blue_planet.id, name: @programme_blue_planet.name, 'genres.name' => @programme_blue_planet.genre.name, 'broadcasters.name' => @programme_blue_planet.broadcaster.name},
            {'programmes.id' => @programme_sherlock_s1.id, name: @programme_sherlock_s1.name, 'genres.name' => @programme_sherlock_s1.genre.name, 'broadcasters.name' => @programme_sherlock_s1.broadcaster.name},
            {'programmes.id' => @programme_sherlock_s2.id, name: @programme_sherlock_s2.name, 'genres.name' => @programme_sherlock_s2.genre.name, 'broadcasters.name' => @programme_sherlock_s2.broadcaster.name},
            {'programmes.id' => @programme_sherlock_s3.id, name: @programme_sherlock_s3.name, 'genres.name' => @programme_sherlock_s3.genre.name, 'broadcasters.name' => @programme_sherlock_s3.broadcaster.name},
            {'programmes.id' => @programme_sherlock_s4.id, name: @programme_sherlock_s4.name, 'genres.name' => @programme_sherlock_s4.genre.name, 'broadcasters.name' => @programme_sherlock_s4.broadcaster.name},
          ]
        )
      end

      context 'with headers' do
        it 'should return array of hashes with given headers' do
          expect(ModelService.to_h(
            table: Programme.joins(:genre).joins(:broadcaster),
            columns: ['programmes.id', :name, 'genres.name', 'broadcasters.name'],
            headers: [:id, :name, :genre, :broadcaster],
          )).to match_array (
            [
              {id: @programme_planet_earth.id, name: @programme_planet_earth.name, genre: @programme_planet_earth.genre.name, broadcaster: @broadcaster_bbc.name},
              {id: @programme_blue_planet.id, name: @programme_blue_planet.name, genre: @programme_blue_planet.genre.name, broadcaster: @broadcaster_bbc.name},
              {id: @programme_sherlock_s1.id, name: @programme_sherlock_s1.name, genre: @programme_sherlock_s1.genre.name, broadcaster: @broadcaster_bbc.name},
              {id: @programme_sherlock_s2.id, name: @programme_sherlock_s2.name, genre: @programme_sherlock_s2.genre.name, broadcaster: @broadcaster_bbc.name},
              {id: @programme_sherlock_s3.id, name: @programme_sherlock_s3.name, genre: @programme_sherlock_s3.genre.name, broadcaster: @broadcaster_bbc.name},
              {id: @programme_sherlock_s4.id, name: @programme_sherlock_s4.name, genre: @programme_sherlock_s4.genre.name, broadcaster: @broadcaster_bbc.name},
            ]
          )
        end
      end

      context 'with index' do
        it 'should return hash of hash with given index' do
          expect(ModelService.to_h(
            table: Programme.joins(:genre).joins(:broadcaster),
            columns: ['programmes.id', :name, 'genres.name', 'broadcasters.name'],
            headers: [:id, :name, :genre, :broadcaster],
            index: :name,
          )).to eq (
            {
              @programme_planet_earth.name => {id: @programme_planet_earth.id, name: @programme_planet_earth.name, genre: @programme_planet_earth.genre.name, broadcaster: @broadcaster_bbc.name},
              @programme_blue_planet.name => {id: @programme_blue_planet.id, name: @programme_blue_planet.name, genre: @programme_blue_planet.genre.name, broadcaster: @broadcaster_bbc.name},
              @programme_sherlock_s1.name => {id: @programme_sherlock_s1.id, name: @programme_sherlock_s1.name, genre: @programme_sherlock_s1.genre.name, broadcaster: @broadcaster_bbc.name},
              @programme_sherlock_s2.name => {id: @programme_sherlock_s2.id, name: @programme_sherlock_s2.name, genre: @programme_sherlock_s2.genre.name, broadcaster: @broadcaster_bbc.name},
              @programme_sherlock_s3.name => {id: @programme_sherlock_s3.id, name: @programme_sherlock_s3.name, genre: @programme_sherlock_s3.genre.name, broadcaster: @broadcaster_bbc.name},
              @programme_sherlock_s4.name => {id: @programme_sherlock_s4.id, name: @programme_sherlock_s4.name, genre: @programme_sherlock_s4.genre.name, broadcaster: @broadcaster_bbc.name},
            }
          )
        end

        context 'and override_id' do
          it 'should return hash of hash with given index and id attribute overriden by the index' do
            expect(ModelService.to_h(
              table: Programme.joins(:genre).joins(:broadcaster),
              columns: ['programmes.id', :name, 'genres.name', 'broadcasters.name'],
              headers: [:id, :name, :genre, :broadcaster],
              index: :name,
              override_id: true,
            )).to eq (
              {
                @programme_planet_earth.name => {id: @programme_planet_earth.name, name: @programme_planet_earth.name, genre: @programme_planet_earth.genre.name, broadcaster: @broadcaster_bbc.name},
                @programme_blue_planet.name => {id: @programme_blue_planet.name, name: @programme_blue_planet.name, genre: @programme_blue_planet.genre.name, broadcaster: @broadcaster_bbc.name},
                @programme_sherlock_s1.name => {id: @programme_sherlock_s1.name, name: @programme_sherlock_s1.name, genre: @programme_sherlock_s1.genre.name, broadcaster: @broadcaster_bbc.name},
                @programme_sherlock_s2.name => {id: @programme_sherlock_s2.name, name: @programme_sherlock_s2.name, genre: @programme_sherlock_s2.genre.name, broadcaster: @broadcaster_bbc.name},
                @programme_sherlock_s3.name => {id: @programme_sherlock_s3.name, name: @programme_sherlock_s3.name, genre: @programme_sherlock_s3.genre.name, broadcaster: @broadcaster_bbc.name},
                @programme_sherlock_s4.name => {id: @programme_sherlock_s4.name, name: @programme_sherlock_s4.name, genre: @programme_sherlock_s4.genre.name, broadcaster: @broadcaster_bbc.name},
              }
            )
          end
        end
      end
    end
  end
end
