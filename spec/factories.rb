FactoryGirl.define do
  factory :player do
    
  end
  factory :piece do
    association :game
    association :player
    
  end

  factory :game do
    sequence :id do |n|
      n
    end
  end
  
end
