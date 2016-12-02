FactoryGirl.define do
  factory :timer do
    association :player
  end
 
  factory :player do
    
    email "testuser@facebook.com"
    password "catsarecool"
    
  end
  
  factory :piece do
    association :game
    association :player
    x_position 4
    y_position 4
  end
  
  factory :pawn do
    type 'Pawn'
  end
  
  factory :king do
    x_position 4
    y_position 4
  end
  
  factory :knight do
    x_position 5
    y_position 5
  end
  
  
  factory :game do
    sequence :id do |n|
      n
    end
    
  end
  
  # Factories for Omniauth
  
  factory :auth_hash, class: OmniAuth::AuthHash do
    
    initialize_with do
      OmniAuth::AuthHash.new({
        provider: provider,
        uid: uid,
        info: {
          email: email,
          nickname: nickname
        }
        })
      end
      
      trait :facebook do
        provider "facebook"
        sequence(:uid)
        email "testuser@facebook.com"
        nickname ""
      end
      
      trait :google do
        provider "google"
        sequence(:uid)
        email "testuser@gmail.com"
        nickname ""
      end
      
      trait :twitter do
        provider "twitter"
        sequence(:uid)
        email ""
        nickname "testuser"
      end
      
      trait :does_not_persist do
        provider "facebook"
        sequence(:uid)
        email ""
        nickname ""
      end
      
    end
    
    
    
  end
  
