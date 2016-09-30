<?php
if('linux' == $_ENV['TERM']){
	echo "\$TERM == linux, cannot use 256 colors.";
	exit;
}

$GLOBALS['escape'] = chr(27) . '[';

function unescape($attr){
	return '\e[' . $attr . 'm';
}

function escape($attr){
	return $GLOBALS['escape'] . $attr . 'm';
}

function print_color($color, $black=false){
	echo escape(($black?'38;5;0;':'').'1;48;5;' . $color) . ' ' . str_pad($color, 3, ' ', STR_PAD_LEFT) .
		 ' ' . escape('0');
}

// 每行，每列，每行方块数
$square_like = array('col' => 6, 'row' => 6, 'eachline' => 3);
$cnt         = 0;
$line        = 0;
$mart        = 1;
$rline       = 0;
$col_p1      = 0;

$lines = array();

// 生成矩阵
for($i = 16; $i < 232; $i++){
	$col_p1++;
	if(0 == $cnt%$square_like['col']){
		$col_p1 = 0;
		$line++;
		if($line > $square_like['row']){
			$line = 1;
			$mart++;
			if(1 == $mart%$square_like['eachline']){
				$rline++;
			}
		}
	}

	$real_line = $rline*$square_like['row'] + $line;
	/**
	 * echo "No. {$cnt} -> Block {$i}, Position {$line},{$col_p1}, Matrix {$mart}(on line {$rline}), color: ";
	 * print_color($i);
	 * echo ".\n";
	 **/

	$black               = ($square_like['col']-$col_p1) <= $line;
	$lines[$real_line][] = array($i, $black);
	$cnt++;
}


echo "属性序列：\n";
$line1=$line2='';
foreach( [1=>'明亮',2=>'黯淡',4=>'下划线',5=>'闪烁',7=>'反色',8=>'隐藏'] as $color=>$name){
	$line1 .= "\t$name\t";
	$line2 .= "\t".escape($color).$color.escape('0')."\t";
}
echo "{$line1}\n{$line2}\n\n";

echo "基础颜色序列：\n\t";
$plat = array();
$i = 0;
while($i<7){
	print_color($i, false);
	$i++;
}
while($i<15){
	print_color($i, true);
	$i++;
}
echo "\n\n";

echo "彩色矩阵：\n";
foreach($lines as $line => $l){
	echo "\t";
	foreach($l as $item => $color){
		print_color($color[0], $color[1]);
		if(5 == $item%$square_like['col']){
			echo "   ";
		}
	}
	if(0 == $line%$square_like['row']){
		echo "\n";
	}
	echo "\n";
}
echo "\n";

echo "灰度：\n\t";
$i = 0;
$black = false;
while($i<24){
	print_color(232+$i, $black);
	$i++;
	if(0==$i%12){
		$black = !$black;
		echo "\n\t";
	}
}
echo "\n\n前景色： \\e[38;5;??m \t\t背景色： \\e[48;5;??m\n\n";
