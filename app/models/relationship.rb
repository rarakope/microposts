class Relationship < ApplicationRecord
  belongs_to :user
  belongs_to :follow, class_name: 'User' 
  #命名規則から外れているので、 class_nameを設定。
  #これにより、follow が Follow という存在しないクラスを参照することを防ぎ、User クラスを参照するものだと明示します。
  #belongs_to :user, class_name: 'User' としてもエラーにはなりませんが、
  #Railsでは『設定よりも規約』の考え方から、省略出来るものは省略して書くことが一般的です
end