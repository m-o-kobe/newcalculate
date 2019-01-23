#たぶん完全版1mおきに全部ばらばらにcrdがとれる
#樹種ごとに集計
#樹種名入れる
#別のプロットの計算する時はxmaxなどの値の変更の必要がないか確認すること
require 'time'
require'timeout'
require "csv"
$targetspp="lc"
plot="int"
hanpuku=1000
p "start"
$random=Random.new
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
	def initialize(num,oyagi,oyakazu) 
		oya=rand(oyakazu)
		kyori=rand(0.0..1.0)
		kaku=rand(0.0..2.0*Math::PI)

		@num = num

		x   = oyagi[oya].x + kyori*Math.sin(kaku)
		y   = oyagi[oya].y + kyori*Math.cos(kaku)
		while x>=$xmax||x<=$xmin||y>=$ymax||y<=$ymin do
			kyori=rand(0.0..1.0)
			kaku=rand(0.0..2.0*Math::PI)

			x   = oyagi[oya].x + kyori*Math.sin(kaku)
			y   = oyagi[oya].y + kyori*Math.cos(kaku)
		end
		@x=x
		@y=y
		
	end
end
	def oyasagasi(trees)
		oyagi=Array.new

		oyagi=trees.select{
				|tree| tree.spp==$targetspp&&tree.dbh01!=0.0
			}
		oyakazu=oyagi.count
		return oyagi,oyakazu
	end
				# for i in 1..1000 do
				# 	oya=rand(oyakazu)
				# 	#親木を選ぶ
				# 	kyori=rand(0.0..1.0)
				# 	kaku=rand(0.0..2.0*Math::PI)
				# 	kouhochi=Tree.new(
				# 		oyagi[oya].x + kyori*Math.sin(kaku),#@x
				# 		oyagi[oya].y + kyori*Math.cos(kaku),#@y
				# 		spp,
				# 		0,#age
				# 		0.1,#size
				# 		0,#@tag.にしておくと割り振られる
				# 		oyagi[oya].tag#mother木のタグ
				# 		)
				# 	ds=0
				# 	@trees.each do |obj|
				# 		_dist =dist(kouhochi, obj)
				# 		if _dist<@settings.spdata(spp,"kanyu4")
				# 			if _dist==0
				# 				ds+=obj.mysize/0.01
				# 			else
				# 				ds+=obj.mysize/_dist
				# 			end
				# 		end
				# 	end
				# 	kanyu=rand(0.0..1.0)
				# 	kanyuritu=1/(1+Math::exp(-@settings.spdata(spp,"kanyu2")-@settings.spdata(spp,"kanyu3")*ds))
				# 	p kanyu,kanyuritu
				# 	if kanyu<kanyuritu
				# 		@trees.push(kouhochi)
				# 		break
				# 	end
				# end


		

class Tree #クラスTreeを定義
	attr_accessor :num, :x, :y, :spp, :dbh01, :dbh04, :hgt #インスタンス変数を読み書きするためのアクセサメソッドを定義
	def initialize( line ) #オブジェクト作成時必ず実行される処理.()内をlineに読み込む
		buf = line.chop.split(",")#lineの最後の文字を消し(chop),","を区切り文字とした配列をbufに読み込み
		
		@num = buf[0].to_i#配列の1列目を整数型に変換して@numに格納。@numはインスタンス変数
		@x   = buf[1].to_f#浮動小数点型。後は同上
		@y   = buf[2].to_f
		@spp = buf[3]
		@dbh01=buf[4].to_f
		@dbh04=buf[5].to_f
		@hgt = buf[6].to_f
	end

	
end
class Array
  def sum
    reduce(:+)
  end

  def mean
    sum.to_f / size
  end

  def var
    m = mean
    reduce(0) { |a,b| a + (b - m) ** 2 } / (size - 1)
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
	
def keisan(zahyou,trees,cr,on)
	zahyou.each do |target|
		if target.x>$xmid
			edge_x=$xmax-target.x
		else
			edge_x=target.x-$xmin
		end
		if target.y>$ymid
			edge_y=$ymax-target.y
		else
			edge_y=target.y-$ymin
		end
			
			
			[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0].each do |lim_dist|#9回作業を繰り返す
				efct = 0.0
				kabuefct=0.0
				
				trees.each do | obj |#treesのデータがobjに格納された上で以下の処理を繰り返す
					
						_dist =dist(target, obj)#targetとobjの距離を_distで返す
						if _dist<lim_dist&&_dist >=(lim_dist-1.0)#もしtargetとobjectの距離が0~9なら(lim_distより)
							if obj.spp==$targetspp
								if _dist==0.0
									kabuefct+=obj.dbh01/0.01
								else
									kabuefct+=obj.dbh01/_dist
								end
							else
								if _dist==0.0
									efct+=obj.dbh01/0.01
								else
									efct+=obj.dbh01/_dist
									
								end
							end
						end
				end
				mensekihi=(sq(lim_dist)*edge_effect(lim_dist, edge_x, edge_y)-sq(lim_dist-1.0)*edge_effect(lim_dist-1.0, edge_x, edge_y))/(sq(lim_dist)-sq(lim_dist-1.0))
		
				crd=efct/mensekihi
				kabu=kabuefct/mensekihi
				cr[lim_dist.to_i-1][target.num]=crd
				on[lim_dist.to_i-1][target.num]=kabu
  
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

############### Calculate


Crd = Array.new(9).map{ Array.new(hanpuku) }
Onaji=Array.new(9).map{ Array.new(hanpuku) }

Kekka1=Array.new(hanpuku-1).map{Array.new(19,0)}
Kekka1[0]=["num","crd1","crd2","crd3","crd4","crd5","crd6","crd7","crd8","crd9","onaji1","onaji2","onaji3","onaji4","onaji5","onaji6","onaji7","onaji8","onaji9"]
parent,parentnumber=oyasagasi(trees)

Ran=[]
begin
	Timeout.timeout(600) do
	
		
	
		for num in 0..hanpuku-1 do
			Ran[num]=Ransu.new(num,parent,parentnumber)
		end

		keisan(Ran,trees,Crd,Onaji)

	
	
end
rescue Timeout::Error
  puts 'おっそーい！'       # タイムアウト発生時の処理
end


CSV.open('n_rand_'+plot+'_'+$targetspp+'1210.csv','w') do |test|
	test << ["plot",plot]
	test << ["spp",$targetspp]
	test<<["num","x","y","crd1","crd2","crd3","onaji1","onaji2","onaji3"]


	for i in 0..hanpuku-1 do
		test << [Ran[i].num,Ran[i].x,Ran[i].y,Crd[0][i],Crd[1][i],Crd[2][i],Onaji[0][i],Onaji[1][i],Onaji[2][i]]
	end
end
