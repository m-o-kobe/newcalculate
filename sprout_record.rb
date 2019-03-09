infile = File.open("crd_ctr_0307.csv", "r")
class Tree #クラスTreeを定義
	attr_accessor :num,
	:x, 
	:y, 
	:spp, 
	:dbh01,
	:dbh04,
	:hgt, 
	:sprout,
	:crd,
	:sc,
	:crd1,
	:crd2,
	:crd3,
	:crd4,
	:crd5,
	:crd6,
	:crd7,
	:crd8,
	:crd9
	def initialize(line) #オブジェクト作成時必ず実行される処理.()内をlineに読み込む
		buf = line.chop.split(",")#lineの最後の文字を消し(chop),","を区切り文字とした配列をbufに読み込み
		@num = buf[0].to_i#配列の1列目を整数型に変換して@numに格納。@numはインスタンス変数
		@x   = buf[1].to_f#浮動小数点型。後は同上
		@y   = buf[2].to_f
		@spp = buf[3]
		@dbh01=buf[4].to_f
		@dbh04=buf[5].to_f
		@hgt = buf[6].to_f
		@sprout=buf[7].to_i
		@sc=buf[8].to_f
		@crd1=buf[9].to_f
		@crd2=buf[10].to_f
		@crd3=buf[11].to_f
		@crd4=buf[12].to_f
		@crd5=buf[13].to_f
		@crd6=buf[14].to_f
		@crd7=buf[15].to_f
		@crd8=buf[16].to_f
		@crd9=buf[17].to_f
		@crd=buf[18].to_f
		@age=buf[19].to_i
	end
end
trees = Array.new#treesを配列として定義
infile.each do |line|#1行目で読み込んだinfileの1行目だけ取り除いてTreeに入れ込む処理？
	if line =~/^#/
	else
		trees.push( Tree.new(line) )
	end
end
sp=[0]
maxdbh=0
sprout=Hash.new
trees.each do |target|
	if sp.include?(target.sprout) then
	else
		sp.push(target.sprout)
		sprout[target.sprout]=trees.select{|item|item.sprout==target.sprout}
	end
	if maxdbh<target.dbh01 then
		maxdbh=target.dbh01
	end
end
#kaisu=maxdbh.div(2)

sp=sp-[0]

spcrd=Hash.new
sp.each do |spnum|
	trees.each do |obj|
		if obj.num==spnum then
			spcrd[spnum]=[obj.crd1,
			obj.crd2,
			obj.crd3,
			obj.crd4,
			obj.crd5,
			obj.crd6,
			obj.crd7,
			obj.crd8,
			obj.crd9]
		end
	end
	# sprout[spnum].each do |target|
	# 	for i in 1..kaisu do
	# 		if i
	# 		end
	# 	end
	# end
end
print(spcrd[4])
file_out = File.open('crd_ctr_sp_0307.csv','w') 
file_out.print "num,crd1,crd2,crd3,crd4,crd5,crd6,crd7,crd8,crd9\n"
sp.each do |spnum|
	file_out.print spnum,","
		spcrd[spnum].each do |sprcrd|
			file_out.print sprcrd,","
		end
		file_out.print "\n"
end

