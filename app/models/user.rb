class User < ApplicationRecord
  before_save { self.email.downcase! } #小文字にする
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  
  
  has_many :relationships 
  # *1
  has_many :followings, through: :relationships, source: :follow
  # *3
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  # *2
  has_many :followers, through: :reverses_of_relationship, source: :user
  # *4
  has_many :favorites
  
  has_many :favorite_posts, through: :favorites, source: :micropost
  
  
  
  #↓f/uf出来るようにするメソッド
  
  def follow(other_user) # *5
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user) # *6
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  #お気に入りを出来るようにするメソッド
  
  
    
  
  
end

=begin 
 *1
  多対多図の左半分にいるUserの1人が自分自身だと仮定すると、
  多対多図の右半分にいる「自分がフォローしているUser」への参照を表しています。
  
 *2
  ⬆逆に、多対多図の右半分に言えるUserの1人が自分自身だと仮定すると、
  上記のrevers_of_relationshipは「多対多図の左半分にいるUserからフォローされている」
  という関係への参照(自分をフォローしているUserへの参照)を表しています。
  reverse~は筆者命名。class_nameで参照するクラスを指定しています。
  Railsの命名規則により、UserからRelationshipを取得する時、
  user_idが使用されます。そのため逆方向では、
  foreign_key: 'follow_id'と指定してuser_id側ではないことを明示します。
  
  ちな、*3 *4をざっくりまとめると、
  既存のリレーションから中間テーブルを経由して、
  向う側にあるモデルを参照してくれるので、
  User から直接、多対多の User 達を取得することができます。
  
 *3
  #has_many:followings・・・「フォローしているUser達」と表現。
  #Modelクラスに対するリレーションではない(Following Modelはない)ので、情報を付け足す。
  #through: relationshipsでhas_many: relationshipsの結果を中間テーブルとして指定しています。
  #更に、その中間テーブルのカラムの中でどれを参照先のidとすべきかをsource: :followで選択しています。
  #（relationshipsテーブルにはfollow_idというカラムが存在する）
  #結果として、user.followingsというメソッドを用いると、suerが中間テーブルrelationshipsを
  #取得し、その一つ一つのrelationshipのfollow_iｄから自分がフォローしているUser達
  #を取得するという処理が可能になります。
  #中間テーブルを経由して相手の情報を取得出来るようにするためにはthroughを使用すると覚える。
  
 *4
  has_many :followers, through: :reverses_of_relationship, source: :user も、
  順方向に対して、逆の設定をしているだけです。through: には
  逆方向の :reverses_of_relationship を指定しており、 source: :user で
  relationships 中間テーブルの user_id のほうが取得したい User だと指定しています。
  これで、user.followers によって、「自分をフォローしている User 達」を
  取得することができます。
  
 *5
  フォローしようとしているother_userが自分ではないか検証。
  selfにはuser.follow(other)を実行した時、userが代入されます。
  つまり、Userのインスタンスがselfとなります。
  更に、self.relationships.find_or_create_by(follow_id: other_user.id)として
  は見つかればRelationを返し、見つからなければ
  self.relationships.create(follow_id: other_user.id)としてフォローの関係を
  保存(create = build + saveのこと)することが出来ます。
  これにより、すでにフォローされている場合に重複して保存されることがなくなります。
  
 *6
  フォローがあればアンフォローしています。
  relationship.destroy if relationshipは、relationshipが存在すれば、destroyします。
  ifはこういうふうにも書けるよ。

 *7
  self.followingsによりフォローしているUser達を取得し、include?(other_user)によって
  other_userが含まれていないかを確認しています。
  含まれている場合には、trueを返し、含まれていない場合には、falseを返します。
  
  
  
  
 *general
  フォロー/アンフォロー（f/uf）では、
  ・自分自身ではないか　・すでにフォローしているか
  を注意する。これらを判定してからf/ufする
  f/ufは、中間テーブルのレコードを保存/削除すること。
  
  参照しているデータが「中間テーブル」なのか「中華テーブルを経由した相手のテーブル」
  なのかを意識して、処理の中身を意識して実装するようにしてください。
  ・メソッドを呼び出すインスタンスは何なのか
  ・メソッドに渡されるインスタンス何なのか
  ・メソッド内で参照しているのは何なのか
  
=end