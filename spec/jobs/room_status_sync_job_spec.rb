require 'rails_helper'

RSpec.describe RoomStatusSyncJob, type: :job do
  describe '#perform' do
    context '空室への同期' do
      it 'active な契約がない occupied の部屋を vacant にする' do
        room = create(:room, status: :occupied)
        create(:contract, room: room, status: :terminated)

        described_class.perform_now

        expect(room.reload.status).to eq 'vacant'
      end

      it 'active な契約がない notice の部屋を vacant にする' do
        room = create(:room, status: :notice)
        create(:contract, room: room, status: :terminated)

        described_class.perform_now

        expect(room.reload.status).to eq 'vacant'
      end

      it 'active な契約がある部屋は vacant にしない' do
        room = create(:room, status: :occupied)
        create(:contract, room: room, status: :active)

        described_class.perform_now

        expect(room.reload.status).to eq 'occupied'
      end

      it 'scheduled_termination な契約がある部屋は vacant にしない' do
        room = create(:room, status: :notice)
        create(:contract, room: room, status: :scheduled_termination)

        described_class.perform_now

        expect(room.reload.status).to eq 'notice'
      end
    end

    context '退去予定への同期' do
      it 'scheduled_termination の契約がある occupied の部屋を notice にする' do
        room = create(:room, status: :occupied)
        create(:contract, room: room, status: :scheduled_termination)

        described_class.perform_now

        expect(room.reload.status).to eq 'notice'
      end

      it '既に notice の部屋は変更しない' do
        room = create(:room, status: :notice)
        create(:contract, room: room, status: :scheduled_termination)

        described_class.perform_now

        expect(room.reload.status).to eq 'notice'
      end
    end

    it '処理結果のハッシュを返す' do
      room1 = create(:room, status: :occupied)
      create(:contract, room: room1, status: :terminated)

      room2 = create(:room, status: :occupied)
      create(:contract, room: room2, status: :scheduled_termination)

      result = described_class.perform_now

      expect(result[:vacated]).to eq 1
      expect(result[:noticed]).to eq 1
    end
  end
end
