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
class Hairetu
	attr_accessor :Crd1,:Crd2,:Crd3,:Crd4,:Crd5,:Crd6,:Crd7,:Crd8,:Crd9,:Onaji1,:Onaji2,:Onaji3,:Onaji4,:Onaji5,:Onaji6,:Onaji7,:Onaji8,:Onaji9
	def initialize()
			@Crd1=["ds1"]
			@Crd2=["ds2"]
			@Crd3=["ds3"]
			@Crd4=["ds4"]
			@Crd5=["ds5"]
			@Crd6=["ds6"]
			@Crd7=["ds7"]
			@Crd8=["ds8"]
			@Crd9=["ds9"]
			@Onaji1=["ss1"]
			@Onaji2=["ss2"]
			@Onaji3=["ss3"]
			@Onaji4=["ss4"]
			@Onaji5=["ss5"]
			@Onaji6=["ss6"]
			@Onaji7=["ss7"]
			@Onaji8=["ss8"]
			@Onaji9=["ss9"]
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
def crdcal(target,object,arei)
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
			
			object.each do | obj |#treesのデータがobjに格納された上で以下の処理を繰り返す
				
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
			if lim_dist==1
				arei.Crd1.push(crd)
				arei.Onaji1.push(kabu)
			elsif lim_dist==2
		    	arei.Crd2.push(crd)
				arei.Onaji2.push(kabu)
		    elsif lim_dist==3
		    	arei.Crd3.push(crd)
				arei.Onaji3.push(kabu)
		    elsif lim_dist==4
		    	arei.Crd4.push(crd)
				arei.Onaji4.push(kabu)
	    	elsif lim_dist==5
		    	arei.Crd5.push(crd)
				arei.Onaji5.push(kabu)
		    elsif lim_dist==6
		    	arei.Crd6.push(crd)
				arei.Onaji6.push(kabu)
		    elsif lim_dist==7
		    	arei.Crd7.push(crd)
				arei.Onaji7.push(kabu)
		    elsif lim_dist==8
		    	arei.Crd8.push(crd)
				arei.Onaji8.push(kabu)
		    else
		    	arei.Crd9.push(crd)
				arei.Onaji9.push(kabu)
		    end
		    
end

end
