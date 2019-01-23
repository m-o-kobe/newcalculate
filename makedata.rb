#1mおきに全部ばらばらにcrdがとれる
#樹種ごとに集計
#樹種名入れる
#別のプロットの計算する時はxmaxなどの値の変更の必要がないか確認すること
require 'time'
require'timeout'
require "csv"

plot="int"
if plot=="ctr"
	infile = File.open("ctrl0904.csv", "r")
	jogai=484
	$xmax=100.0
	$ymax=50.0
	$xmin=0.0
	$ymin=0.0
elsif plot=="int"
	infile = File.open("int0905.csv", "r")
	jogai=484
	$xmax=50.3
	$ymax=50.0
	$xmin=0.0
	$ymin=-50.0
end

$xmid=$xmin+($xmax-$xmin)/2
$ymid=$ymin+($ymax-$ymin)/2
class Ransu #クラスTreeを定義
	attr_accessor :num, :x, :y
	def initialize(num) 
		@num = num
		@x   = $random.rand($xmin..$xmax).to_f
		@y   = $random.rand($ymin..$ymax).to_f
	end
end
$sprout=1
class Tree #クラスTreeを定義
	attr_accessor :num, :x, :y, :spp, :dbh01, :dbh04, :hgt,:sprout #インスタンス変数を読み書きするためのアクセサメソッドを定義

	def initialize( line ) #オブジェクト作成時必ず実行される処理.()内をlineに読み込む
		buf = line.chop.split(",")#lineの最後の文字を消し(chop),","を区切り文字とした配列をbufに読み込み
		
		@num = buf[0].to_i#配列の1列目を整数型に変換して@numに格納。@numはインスタンス変数
		@x   = buf[1].to_f#浮動小数点型。後は同上
		@y   = buf[2].to_f
		@spp = buf[3]
		@dbh01=buf[4].to_f
		@dbh04=buf[5].to_f
		@hgt = buf[6].to_f
		@sprout=0
	end

	
end
class Array
  def sum
    reduce(:+)
  end

  def sd
    Math.sqrt(var)
  end
end
def dgrw(dbh04,dbh01)#dgrwは成長量
		return (dbh04-dbh01)/3
end
	
def sq (_flt)
	return _flt * _flt
end
def dist( tree_a, tree_b )
	return Math::sqrt(sq(tree_a.x - tree_b.x) + sq(tree_a.y - tree_b.y))#木aと木bの距離。sqは上で定義されている
end


def edge_effect( a, x, y )#エッジ効果は林縁部にかかる効果
	if  y > x	# yがxより大きかったらxとyを入れ替えるためのif　よって常にx>y
		_tmp = x
		x = y
		y = _tmp
	end

	#####################
	if( x >=a && y >=a )
		return 1.0
	else
		if( x >=a && y < a )
			return( Math::PI*sq(a) - sq(a)*Math::acos(y/a) + y*Math::sqrt( sq(a)-sq(y) ) ) / (sq(a)*Math::PI)
		else
			if( x*x+y*y < a * a )
				return ( Math::PI*sq(a)/4 + x*y+ x*Math::sqrt( sq(a)-sq(x) )/2 + y*Math::sqrt( sq(a) -sq(y) )/2 + sq(a)*Math::asin(x/a)/2 + sq(a)*Math::asin(y/a)/2 ) / ( sq(a) * Math::PI )
			else
				return ( sq(a) * Math::PI - sq(a)*Math::acos(x/a) + x*Math::sqrt( sq(a)-sq(x) ) -sq(a)*Math::acos(y/a) + y*Math::sqrt( sq(a) -sq(y) ) )/ (sq(a) * Math::PI )
			end
		end
	end
end
	
def keisan(zahyou,trees)
	zahyou.each do |target|
		if target.spp=="lc" then
			target.spp=1
		elsif target.spp=="pt"
			target.spp=3
		elsif target.spp=="bp" then
			target.spp=2
			trees.each_with_index do | obj,i |#treesのデータがobjに格納された上で以下の処理を繰り返す
		 
				_dist =dist(target, obj)#targetとobjの距離を_distで返す
				if _dist<=1.0&&obj.sprout!=0 then
					target.sprout=obj.sprout
					break
				
				end
				if i==trees.length-1 then
					target.sprout=$sprout
					$sprout+=1
				end
			end
		else
			target.spp=4

		end
 
	end

end	


############## read file
trees = Array.new#treesを配列として定義
infile.each do |line|#1行目で読み込んだinfileの1行目だけ取り除いてTreeに入れ込む処理？
	if line =~/^#/
	else
		trees.push( Tree.new(line) )
	end
end
trees.delete_if{
	|tree| tree.dbh01==0.0
}
betula=Array.new
betula=trees.select{
	|tree| tree.spp=="bp"
}
############### Calculate

begin
	Timeout.timeout(600) do


		keisan(trees,betula)

end
rescue Timeout::Error
  puts 'おっそーい！'       # タイムアウト発生時の処理
end

CSV.open('init_'+plot+'_'+'1212.csv','w') do |test|
	test << ["#plot",plot]
	test<<["#x","y","sp","age","mysize","tag","sprout"]
	trees.each do |tree|
		test << [tree.x,tree.y,tree.spp,0,tree.dbh01,tree.num,tree.sprout]
	end
end
