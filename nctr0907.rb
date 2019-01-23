#たぶん完全版1mおきに全部ばらばらにcrdがとれる
#樹種ごとに集計
#樹種名入れる
#別のプロットの計算する時はxmaxなどの値の変更の必要がないか確認すること

infile = File.open("ctrl0904.csv", "r")

targetspp="lc"

xmax=100
ymax=50
xmin=0
ymin=0
xmid=xmin+(xmax-xmin)/2
ymid=ymin+(ymax-ymin)/2


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
	
	


############## read file
trees = Array.new#treesを配列として定義
infile.each do |line|#1行目で読み込んだinfileの1行目だけ取り除いてTreeに入れ込む処理？
	if line =~/^#/
	else
		trees.push( Tree.new(line) )
	end
end

############### Calculate


Num=["num"]
Xx=["x"]
Yy=["y"]
Spp=["spp"]
Dbh01=["dbh01"]
Dbh04=["dbh04"]
Hgt=["hgt"]
Crd1=["crd1"]
Crd2=["crd2"]
Crd3=["crd3"]
Crd4=["crd4"]
Crd5=["crd5"]
Crd6=["crd6"]
Crd7=["crd7"]
Crd8=["crd8"]
Crd9=["crd9"]
Kabudachi=["kabudachi"]
Dgrw=["growth"]



trees.each do |target|
	if target.dbh01<2.0&&target.dbh01>0.0&&target.x<=xmax&&target.x>=xmin&&target.y<=ymax&&target.y>=ymin&&target.spp.include?(targetspp)
		Num.push(target.num)
		Xx.push (target.x)
		Yy.push(target.y)
		Spp.push(target.spp)
		Dbh01.push(target.dbh01)
		Dbh04.push(target.dbh04)
		Hgt.push(target.hgt)
		if target.x>xmid
			edge_x=xmax-target.x
		else
			edge_x=target.x-xmin
		end
		if target.y>ymid
			edge_y=ymax-target.y
		else
			edge_y=target.y-ymin
		end
		
		
		[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0].each do |lim_dist|#9回作業を繰り返す
			efct = 0.0
			kabu=0.0
			trees.each do | obj |#treesのデータがobjに格納された上で以下の処理を繰り返す
				if obj.num != target.num#obj.num≠target.numberならば･･･
					_dist =dist(target, obj)#targetとobjの距離を_distで返す
					if _dist<lim_dist&&_dist >=(lim_dist-1.0)#もしtargetとobjectの距離が0~9なら(lim_distより)
						if obj.spp.include?(targetspp)&&lim_dist==1
							if _dist==0.0
								kabu+=obj.dbh01/0.01
							else
								kabu+=obj.dbh01/_dist
							end
						else
							efct+=obj.dbh01/_dist
						end
					end
				end
			end
			mensekihi=(sq(lim_dist)*edge_effect(lim_dist, edge_x, edge_y)-sq(lim_dist-1.0)*edge_effect(lim_dist-1.0, edge_x, edge_y))/(sq(lim_dist)-sq(lim_dist-1.0))
	
			crd=efct/mensekihi
		    
	
			if lim_dist==1
				Crd1.push(crd)
				Kabudachi.push(kabu)
			elsif lim_dist==2
		    	Crd2.push(crd)
		    elsif lim_dist==3
		    	Crd3.push(crd)
		    elsif lim_dist==4
		    	Crd4.push(crd)
	    	elsif lim_dist==5
		    	Crd5.push(crd)
		    elsif lim_dist==6
		    	Crd6.push(crd)
		    elsif lim_dist==7
		    	Crd7.push(crd)
		    elsif lim_dist==8
		    	Crd8.push(crd)
		    else
		    	Crd9.push(crd)
		    end
		    
		end


	Dgrw.push(dgrw(target.dbh04,target.dbh01))

	end	

	
		

	
end
kazu=Num.count-1


require "csv"

CSV.open('nctrl0907lc.csv','w') do |test|
	for i in 0..kazu do
		test << [Num[i], Xx[i],Yy[i],Spp[i],Dbh01[i],Dbh04[i],Hgt[i],Crd1[i],Crd2[i],Crd3[i],Crd4[i],Crd5[i],Crd6[i],Crd7[i],Crd8[i],Crd9[i],Kabudachi[i],Dgrw[i]]


	end
	


end