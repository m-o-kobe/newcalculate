$targetspp="pt"#ここで樹種を変える"pt"or"bp"or"lc"
plot="ctr"
$cal="da"#"da"or"grow"
limlim=8

if plot=="ctr"
	infile = File.open("ctrl0115.csv", "r")#ここにファイル名を入れる
	#infile = File.open("test.csv", "r")
	$jogai=484#計算から除外したい木はこのように表記
	$xmax=100.0#プロットサイズ
	$ymax=50.0
	$xmin=0.0
	$ymin=0.0
elsif plot=="int"
	infile = File.open("int0121.csv", "r")
	$jogai=484
	$xmax=50.3
	$ymax=50.0
	$xmin=0.0
	$ymin=-50.0
end
$xmid=$xmin+($xmax-$xmin)/2
$ymid=$ymin+($ymax-$ymin)/2
class Tree #クラスTreeを定義
	attr_accessor :num, :x, :y, :spp, :dbh01, :dbh04, :hgt, :sprout#インスタンス変数を読み書きするためのアクセサメソッドを定義
	def initialize( line ) #オブジェクト作成時必ず実行される処理.()内をlineに読み込む
		buf = line.chop.split(",")#lineの最後の文字を消し(chop),","を区切り文字とした配列をbufに読み込み
		
		@num = buf[0].to_i#配列の1列目を整数型に変換して@numに格納。@numはインスタンス変数
		@x   = buf[1].to_f#浮動小数点型。後は同上
		@y   = buf[2].to_f
		@spp = buf[3]
		@dbh01=buf[4].to_f
		@dbh04=buf[5].to_f
		@hgt = buf[6].to_f
		@sprout=buf[7].to_i
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
	if y<0
		print x
		print y
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
def death(dbh04)
	if dbh04==0
		return 0
	else
		return 1
	end
end	
def dorg(target)
	if $cal=="grow"
		if target.dbh04!=0.0&&target.spp.include?($targetspp)&&target.dbh01!=0.0&&target.x<=$xmax&&target.x>=$xmin&&target.y<=$ymax&&target.y>=$ymin&&target.num!=$jogai
			return true
		end
	elsif $cal=="da"
		if target.dbh01!=0.0&&target.spp.include?($targetspp)&&target.x<=$xmax&&target.x>=$xmin&&target.y<=$ymax&&target.y>=$ymin
			return true
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
Num=Array.new
Xx=Array.new
Yy=Array.new
Spp=Array.new
Dbh01=Array.new
Dbh04=Array.new
Hgt=Array.new
Crd = Array.new(trees.length).map{ Array.new(limlim) }

Kabudachi=Array.new
Dgrw=Array.new
Death=Array.new
count=0
trees.each do |target|
	if dorg(target)==true
		Num.push(target.num)
		Xx.push (target.x)
		Yy.push(target.y)
		Spp.push(target.spp)
		Dbh01.push(target.dbh01)
		Dbh04.push(target.dbh04)
		Hgt.push(target.hgt)
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
		for lim_dist in 1..limlim do
			efct = 0.0
			kabu=0.0
			trees.each do | obj |#treesのデータがobjに格納された上で以下の処理を繰り返す
				if obj.num != target.num#obj.num≠target.numberならば･･･
					_dist =dist(target, obj)#targetとobjの距離を_distで返す
					if _dist<lim_dist&&_dist >=(lim_dist-1.0)#もしtargetとobjectの距離が0~9なら(lim_distより)
						if target.sprout==obj.sprout&&target.sprout!=0
							if _dist<=0.01
								kabu+=obj.dbh01/0.01
							else
								kabu+=obj.dbh01/_dist
							end
						else
							if _dist<=0.0
								efct+=obj.dbh01/0.01
							else
								efct+=obj.dbh01/_dist
							end
						end
					end
				end
			end
			mensekihi=(sq(lim_dist)*edge_effect(lim_dist, edge_x, edge_y)-sq(lim_dist-1.0)*edge_effect(lim_dist-1.0, edge_x, edge_y))/(sq(lim_dist)-sq(lim_dist-1.0))
			crd=efct/mensekihi
			Crd[count][lim_dist.to_i-1]=crd
			if lim_dist==1 then
				Kabudachi[count]=kabu

			end
			
		end
	Dgrw.push(dgrw(target.dbh04,target.dbh01))
	Death.push(death(target.dbh04))
	count=count+1
	end


end

kazu=Num.count-1
Kekka1=Array.new(kazu+2).map{Array.new(8+limlim)}
Kekka1[0]=["num","x","y","spp","dbh01","dbh04","hgt","sc",$cal,"Crd1"]
for i in 2..limlim do
	Kekka1[0].push("Crd"+i.to_s)
end


for j in 0..kazu

		Kekka1[j+1][0]=Num[j]
		Kekka1[j+1][1]=Xx[j]
		Kekka1[j+1][2]=Yy[j]
		Kekka1[j+1][3]=Spp[j]
		Kekka1[j+1][4]=Dbh01[j]
		Kekka1[j+1][5]=Dbh04[j]
		Kekka1[j+1][6]=Hgt[j]
		Kekka1[j+1][7]=Kabudachi[j]
		if $cal=="grow" then
			Kekka1[j+1][8]=Dgrw[j]
		elsif $cal=="da"
			Kekka1[j+1][8]=Death[j]
		end
		for i in 0..limlim-1 do
		
			Kekka1[j+1][9+i]=Crd[j][i]
		end

end
require "csv"
CSV.open($cal+'_'+plot+'_'+$targetspp+'0121.csv','w') do |test|#出力ファイル名変えたいならここ
	for i in 0..kazu+1 do
		test<<Kekka1[i]
	end
end