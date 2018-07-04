<?
set_time_limit(3);
ini_set('max_execution_time', '3');
session_start();
$CHMakerVersion = "3.0.10";
class codeblockdata{
	var $names;
	var $canshu=[];
	var $code;
}

class CHbianliangData{
    var $name;
    var $type; //为0 则为"字符串"有转义符 1 则为 '字符串'
    var $Parents;
    var $text;
}

class ChObjects{
    var $obj;
    var $names;
    var $type;//0 为object   1为dll对象
    var $hwnd;
}

global $代码块数;
$代码块数=0;
global $代码块;
$代码块=[];
global $对象数;
$对象数=0;
global $对象;
$对象=[];
global $变量数;
$变量数=0;
global $最大变量数;
$最大变量数=5000;
global $变量;
$变量=[];

global $变量NoMoney;$变量NoMoney=false;
global $CHDebug;$CHDebug=false;
global $CHDebugPath;$CHDebugPath='';
global $ErrDescription;$ErrDescription='';
global $ErrNumber;$ErrNumber=0;
global $ExitFunction;$ExitFunction=false;
global $StopProgram;$StopProgram=false;
global $ErrorIgnore;$ErrorIgnore=false;
global $ErrNumber;
global $ErrDescription;$ErrDescription='';
global $MakeCode;
function Init(){}//初始化？

//instr   InStr_php
//mid     Mid_php
function GetCode(){
	global $MakeCode;
    return $MakeCode;
}
function getVersion(){
    return $CHMakerVersion;
}
function Delay($Msec){}

function AppPath(){
    return 'C:\system32\ch3\\';
}
function howmuch($s,$t){
	return (strlen($s)-strlen(str_replace($t,'',$s)))/strlen($t);
}
function TrimCodeBlock($code){
	if(InStr_php($code,'{')){
		$sposn1=1;
		do{
			$posdn1 = InStr_php($code, "{",$sposn1);
			$sposn1 = 1 + $posdn1;
			if ($posdn1 != 0) {
				$sposn2 = $sposn1;
				do{
					$posdn2 = InStr_php($code, "}",$sposn2);
					$sposn2 = 1 + $posdn2;
					if ($posdn2 == 0)SendError("}丢失！");
					$centertext = Mid_php($code, $posdn1 + 1, $posdn2 - $posdn1 - 1);
					//Dim dkhnn As Boolean
					$dkhnn = howmuch($centertext, "{") == howmuch($centertext, "}");
					if ($dkhnn){
						$tempcode = TrimCodeBlock($centertext);
						$code = str_replace("{" . $centertext . "}", AddCodeBlock($tempcode),$code);
					}
				}while(!$dkhnn);
			}
		}while($posdn1 != 0);
	}
	return $code;
}
function AddCodeBlock($code){
	global $代码块数;
	global $代码块;
	$codeblock=new codeblockdata();
    $codeblock->code = $code;
    $codeblock->names = "ch_".sprintf("%08d",$代码块数);
	
	$代码块[]=$codeblock;$代码块数 = $代码块数 + 1;
	//print('///'.$codeblock->names.'\\\\\\');
    return "ch_" . sprintf("%08d",$代码块数-1);
}
function AddCusFunc($FuncName, $Code, $canshu){
	global $代码块数;
	global $代码块;
	$codeblock=new codeblockdata();
    $codeblock->code = $Code;
    $codeblock->names = $FuncName;
    //Dim Canshuele, CanShuEleN As Long
    if (count($canshu) != 0){
        //ReDim 代码块(代码块数).canshu(UBound(canshu))
        foreach($canshu as $Canshuele){
			$codeblock->canshu[] = $Canshuele;
        }
	}
	$代码块[]=$codeblock;$代码块数 = $代码块数 + 1;
    return $FuncName;
}
function Run($Code){
	global $MakeCode;
    重置(0);
	p("开始运行CH程序");
    $Code = TrimCode($Code);
	p("trimecode success");
    if (Mid_php($Code, -1) != ";")$Code = $Code . ";";
    $Code = $Code . "die;";
    if (!CheckCode($Code))return false;
	p("代码检查完成！");
	p('现在:'.$Code."|开始运行！");
    $Code = 计算表达式($Code);
	p('res:'.$Code."|");
    $MakeCode = $Code;
    return true;
}
function CheckCode($code){
	return true;
}
function TrimCode($Code){
	if (strlen($Code) ==0) return '';
	//print('1:'.strlen($Code));
    $n = 0;
    //Dim n2 As Long, nn As Long
    $nn = 1;
    while (InStr_php($Code, "//",$nn) <> 0){
        $n2 = InStr_php($Code, "//",$nn);
        $n = InStr_php($Code, "\n",$n2 + 2);
        if ($n != 0){
            $Code = Mid_php($Code, $nn, $n2 - $nn) . Mid_php($Code, $n);
        }else{
            $Code = Mid_php($Code, $nn, $n2 - $nn);
            $n = strlen($Code);
		}
    }
    $Code = str_replace("\n", "",$Code);
    $n = 0;
    $nn = 1;
	if (strlen($Code) ==0) return '';
	//print(strlen($Code));
	//if(InStr_php($Code, "/*",$nn) != false)print('ok');else print('no');
	//die();
    while (InStr_php($Code, "/*",$nn) != false){
        $n2 = InStr_php($Code, "/*",$nn);
        $n = InStr_php($Code, "*/",$n2 + 2);
        if($n == 0){SendError("注释/**/未关闭");return '';}
        $Code = Mid_php($Code, $nn, $n2 - $nn) . Mid_php($Code, $n + 2);
	}
	p("转出字符串前：".$Code);
    $Code = 转储字符串($Code);
	p("转出字符串后：".$Code);
	//print('<br />'.$Code.'<br />');
    $Code = str_replace(chr(9), "",$Code);
    $Code = 不区分大小写($Code);
    $Code = CodeBlockSave($Code);
    return trim($Code);
}

function CodeBlockSave($Code){
	$代码块数 = 0;
    $ttcode = $Code;
    return TrimCodeBlock($ttcode);
}
function Much($s, $t){
    return InStr_php($s, $t)!=0;
}

function Singles($s, $t){
    $charn = Howmuch($s, $t);
    if (intval($charn / 2) <> $charn / 2 ) return true; else return false;
}
function SingleNum($s){
    if (intval($s / 2) != $s / 2) return true; else return false;
}
function 不区分大小写($texts){
    /*$nunnn ='';
    $ntexx=[];
    $nusns ='';
    if($texts=='')return '';
    $nunnn=howmuch($texts,'"');
    $ntexx=explode($texts, '"');
    if($nunnn/2==intval($nunnn/2)){
        for($nusns=0;$nusns>=$nunnn;$nusns=$nusns+2){
            $ntexx[$nusns]= strtolower($ntexx[$nusns]);
        }
    }
    return join('"',$ntexx);*/
	return $texts;
}
function 加变量($names, $texts, $types){
	global $变量数;
	global $变量;
	p('加变量！'."$names, $texts, $types");
	if (!检测变量合法性($names)){SendError("变量名不正确！");return '';}
	p('加变量开始');
	for ($bln=0;$bln<=$变量数-1;$bln++){
		if ($names == $变量[$bln]->name){
			//$bianliang=new CHbianliangData();
			//$bianliang->text = $texts;
			//$bianliang->type = $types;
			p('加变量时发现重复变量，改变量:'.$names."|".$texts);
			
			$变量[$bln]->text=$texts;//$变量数 = $变量数 + 1;
			return '';
		}
	}
	$bianliang=new CHbianliangData();
    $bianliang->name = $names;//变量前面要加$  这里存储不加$
    $bianliang->text = $texts;
    $bianliang->type = $types;
	$变量[]=$bianliang;$变量数 = $变量数 + 1;
	p('加变量:'.$names."|".$texts);
	return '';
}
function val($nust){
	return $nust;
}
function 读变量($names){//需手动trim
	global $变量;
	global $变量数;
	p('读变量:'.$names."现在：".$变量数);
    for ($bianliangn = 0;$bianliangn<=$变量数 - 1;$bianliangn++){
		p('读取变量ing:'.$变量[$bianliangn]->name."==".$names);
        if ($变量[$bianliangn]->name == $names){
			p('读变量成功:'.$变量[$bianliangn]->text);
			return $变量[$bianliangn]->text;
		}
		
	}
	
}
function 取变量地址($names){
	global $变量数;
	global $变量;
    for ($i = 0;$i<=$变量数 - 1;$i++){
        if ($变量[$i]->text = $names) {
            return $变量[$i]->name;
		}
	}
}
function 判断变量类型($names){
	global $变量;
	global $变量数;
    for ($bianliangn = 0;$bianliangn<=$变量数;$bianliangn++){
        if ($变量[$bianliangn]->name == $names) return $变量[$bianliangn]->type;
    }
}
//print('test');
//print('left:'.left('abcdef',2));


function 第一运算优先($表达式){
	global $ExitFunction;
	global $StopProgram;
    /*Dim tempbiaodashi As String
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String, c3 As String
    Dim n As Long, n1 As Long, n2 As Long, n3 As Long, posn As Long
    Dim result As String, str As String, strs As String
    Dim $符号 As String
    Dim dengyu As Boolean
    Dim noact As Boolean*/
		/*
    'if($表达式 <> ""){
    '    if(Right($表达式, 1) <> ";"){
    '        if(Much($表达式, ";")){
    '$表达式 =$表达式 . ";"
    '        End if('    End if('End if(*/
    $posn = 0;
	$pos1=0;
	$pos2=0;
    $n1 = InStr_php($表达式, "(",$posn);
    $n2 = InStr_php($表达式, ";",$posn);
	p('第一运算表达式:'.$表达式);
	p('第一运算begdoublenum:'.$n1.$n2.'|第一运算');
	//die();
    $n = 999999;
    if ($n1 < $n && $n1 != 0){
        $符号 = "(";
        $n = $n1;
	}
    
    if ($n2 < $n && $n2 != 0){
        $符号 = ";";
        $n = $n2;
	}
    p('第一运算beg:'.$n.'|第一运算end');

    if ($n == 999999) {$n = 0;}
	//if ($n !== false)print('第一成立');else print('第一不成立');
    while($n != 0){
		
        $c1 = "";
        $c2 = "";
		$c3 = "";
		p('循环准备：'."$pos2=$n-1;$pos2>=1;$pos2");
        for($pos2=$n-1;$pos2>=1;$pos2--){ //'前面的
			p('循环：'."{$n}-1哈哈本次{$pos2}");
            if ($符号 == "("){
                if (Much("+-*/\%&|.^!=", Mid_php($表达式, $pos2, 1))){
                    $pos2 = $pos2 + 1;
                    break;
                }else{
                    if (Mid_php($表达式, $pos2, 1) == "="){
                        if ($pos2 == $n - 1){

                        }else{
                            $pos2 = $pos2 + 1;
                        }
                        break;
                    }
               	}
                
            }
            if ($pos2 == 1) break;
        }
		p("c1:"."Mid_php($表达式, $pos2, $n - $pos2)");
        if ($pos2 == 0) $c1 = ""; else $c1 = trim(Mid_php($表达式, $pos2, $n - $pos2));
        for ($pos1 = $n + 1; $pos1<= strlen($表达式);$pos1++){ //后面的
            if ($符号 == ";"){
                if (Much(";", Mid_php($表达式, $pos1, 1))){
                    $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n));
                    if (Howmuch($c2, "(") == Howmuch($c2, ")")){
                        $pos1 = $pos1 - 1;
                        $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n));
                        break;
					}
				}
            }
            if ($符号 == "("){
                if (Much(")", Mid_php($表达式, $pos1, 1))){
                    $str = Mid_php($表达式, $n + 1, $pos1 - $n - 1);
                    if (Howmuch($str, "(") == Howmuch($str, ")")){
                        //pos1 = pos1 - 1
                        break;
					}
				}
			}
            if($pos1 == strlen($表达式))break;
		}
        if($pos1 > strlen($表达式))$pos1 = strlen($表达式);
            
        if ($c2 <> ""){
            //c2 = c2
		}else{
            //if($符号 = ";"){ n = n - 1
			
            if ($pos1 - $n - 1 >= 0){
				p("第一c2计算1$pos1 - $n - 1 >= 0成立");
                if ($符号 == ";"){
                    $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n));
                }else{
                    $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n - 1));
                }
            }else{
				p("第一c2计算1$pos1 - $n - 1 >= 0不成立");
                $n = $n - 1;
				p("计算：trim(Mid_php($表达式, $n + 1, $pos1 - $n - 1));");
                $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n - 1));
            }
			p("第一c2计算结果：".$c2);
			
            //c3 = ""
			//print('error'.$表达式);
			//print('<hr />error:'.$表达式."|".($pos1 + 1) .'res:'."|");
			//die();
			
            if (InStr_php($表达式, ";",$pos1 + 1) - $pos1 - 1 > 0){
                $c3 = Mid_php($表达式, $pos1 + 1, InStr_php($表达式, ";") - $pos1 - 1,$pos1 + 1);
            }
            $pos1 = $pos1 + strlen($c3);
		}
        $result = "";
        if ($符号=='('){
                if (!$ExitFunction)$result = 执行函数($c1, $c2, $c3);
                if ($StopProgram)return '';
		}elseif ($符号==';'){
        	p('第一:富豪是分毫');
			$result = "";
			if ($c1 == "" && $c2 == ""){
			}else{
				p('开始计算1：'.$c1);
				if ($c1 <> "die" && $c1 <> ""){
					if (!$ExitFunction){
						
						$result = 计算表达式($c1);
					}
				}
				if($StopProgram)return '';
				p('开始计算2：'.$c2);
				if($c2 <> "die" && $c2 <> ""){
					if (!$ExitFunction){
						
						$result = 计算表达式($c2);
					}
				}
				if($StopProgram)return '';
			}
		}
		/*
        'result = 转添字符串(result)
        'if(result = """"""){ result = ""
        'if(result = "''"){ result = ""
        
        'if(result <> "true" && result <> "false" && result <> ""){ result = 转添字符串(result)
		*/
        if ($result <> ""){$result = 转添字符串($result);};
        if ($pos2 == 0){$pos2 = 1;}
	/*
        'result = 转字符串(result)
        'result = ""
        'if(result = ""){ result = "''"*/
        if(strlen($表达式) < $pos1)$pos1 = strlen($表达式);
		p("第一大合并：当前：".$表达式);
        $表达式 = left($表达式, $pos2 - 1) . $result . right($表达式, strlen($表达式) - $pos1);
		p("第一大合并结束：当前：".$表达式);
        if (left($表达式, 1) == ";") $表达式 = Mid_php($表达式, 2);
        if ($posn == 0 ) $posn = 1; //'       '123/r/n354'
        $posn = strlen($result) + $pos2;
        if ($表达式 == "" )$posn = 0;
        if ($posn <> 0){
            $n1 = InStr_php($表达式, "(",$posn);
            $n2 = InStr_php($表达式, ";",$posn);
            $n = 999999;
            if ($n1 < $n && $n1 <> 0){
                $符号 = "(";
                $n = $n1;
            }
            if ($n2 < $n && $n2 <> 0){
                $符号 = ";";
                $n = $n2;
            }
            if ($n == 999999) $n = 0;
		}else{
            $n = 0;
		}
	}
    return $表达式;
    //Debug.Print$表达式
}
function 单目运算优先($表达式){
/*
''''''!true  false
''''''++$a
''''''--$a
''''''$a++
''''''$a--
*/

    /*Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, n3 As Long, posn As Long
    Dim result As String, str As String
    Dim $符号 As String
    Dim dengyu As Boolean
    Dim noact As Boolean*/
	p('-------------单目运算优先输如入:'.$表达式);
    $posn = 1;
	$result='';
    $n1 = InStr_php($表达式, "!",$posn);
    $n2 = InStr_php($表达式, "+",$posn);
    $n3 = InStr_php($表达式, "-",$posn);
    
    $n = 999999;
    if( $n1 < $n && $n1 <> 0 ){
        $符号 = "!";
        $n = $n1;
    }
    if( $n2 < $n && $n2 <> 0 ){
        $符号 = "+";
        $n = $n2;
    }
    if( $n3 < $n && $n3 <> 0 ){
        $符号 = "-";
        $n = $n3;
    }
    if($n == 999999)$n = 0;
    while ($n <> 0){
		p('单目运算优先循环:'.$n);
        $c1 = "";
        $c2 = "";
        $dengyu = false;
        $noact = false;
        for($pos2 = $n - 1;$pos2>=1;$pos2--){//'前面的
            if(Much("+-!&|=<>^", Mid_php($表达式, $pos2, 1)) ){
                $pos2 = $pos2 + 1;
				break;
            }
            if( $pos2 == 1 )break;
		}
        if($pos2 == 0 ){ $pos2 = 1;}
        if($pos2 == 0 ){ $c1 = "";}else{$c1 = trim(Mid_php($表达式, $pos2, $n - $pos2));}
        if($符号 == "+" || $符号 == "-" ){
            if($符号 == "+"){
                if( Mid_php($表达式, $n + 1, 1) == "+")$dengyu = true;
            }
            
            if($符号 == "-"){
                if(Mid_php($表达式, $n + 1, 1) == "-")$dengyu = true;
            }
            if(!$dengyu ){
                if($符号 == "+" ) $noact = true;
                if($符号 == "-" ){
                    if( $c1 <> "" )$noact = true;
                }
            }
        }
        if($dengyu) $n = $n + 1;
        for ($pos1 = $n + 1;$pos1 <= strlen($表达式);$pos1++){ //'后面的
            if($符号 == "+" || $符号 == "-" ){
                if(Much("+-!&|=^<>", Mid_php($表达式, $pos1, 1))){
                    if($dengyu){$pos1 = $pos1 - 1;break;}
                }
            }
            if( $符号 == "!" ){
                if( Much("+-&|=^<>", Mid_php($表达式, $pos1, 1)) ){
                    $pos1 = $pos1 - 1;
					break;
                }
            }

            if( $pos1 == strlen($表达式))break;
        }
        //'if( much($表达式, "&&") || much($表达式, "||") ){ noact = true
        if($pos1 > strlen($表达式)) $pos1 = strlen($表达式);
        if($dengyu){$n = $n - 1;}
        if(($符号 == "+" || $符号 == "-") && $dengyu == true ){
            if( $c1 <> "" && $c2 <> "" ){
                $SendError("单目运算错了？");
                $result = 0;
                $noact = true;
            }
        }elseif($符号 == "+" && !$dengyu ){
            $noact = true;
        }
        if($符号 == "!" ){
            $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n));
            if($c2 =="")$noact = true;
        }
		p('单目danmu运算c1:'.$c1);
		p('单目运算c2:'.$c2);
        if(!$noact){
            
            if( $dengyu ) $n = $n + 1;
            if( $c2 <> "" ){
                $c2 = $c2; //'计算表达式(c2)
            }else{
                if( $pos1 - $n < 0 ){ $pos1 = $n;}
                $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n));
            }
            p('单目运算优先开始判断符号:');
            if ($符号=="!"){
                //Case "!"
				if( $c1 == "" && $c2 <> "" ){
					$result = 计算表达式(c2);
					if( $result == "true" ){
						$result = false;
					}elseif( $result == "false" ){
						$result = true;
					}
				}
			}elseif($符号=="+"){
				p('单目运算优先加法:');
                //Case "+"
                    if($dengyu){
                        if($c1 == "" && $c2 <> ""){
                            $result = Val(读变量($c2)) + 1;
                            加变量($c2, Val(读变量($c2)) + 1, 2);
                        }elseif($c1 <> "" && $c2 == ""){
                            $result = Val(读变量($c1));
                            加变量($c1, Val(读变量($c1)) + 1, 2);
                        }
                    }
                //Case "-"
			}elseif($符号=="-"){
				if($dengyu ){
					if( $c1 == "" && $c2 <> "" ){
						$result = Val(读变量($c2)) - 1;
						加变量($c2, Val(读变量($c2)) - 1, 2);
					}elseif( $c1 <> "" && $c2 == "" ){
						$result = Val(读变量($c1));
						加变量($c1, Val(读变量($c1)) - 1, 2);
					}
				}else{
					if($c1 == "" && $c2 != ""){$result = 转储字符串("-" . $c2);}else{$noact = true;}
				}
            }
            if( $pos2 == 0 ){
                $表达式 = Left($表达式, $pos2) . $result . Right($表达式, strlen($表达式) - $pos1);
            }else{
                $表达式 = Left($表达式, $pos2 - 1) . $result . Right($表达式, strlen($表达式) - $pos1);
            }
            if( $posn == 0 ){ $posn = 1;}
            $posn = strlen($result) + $pos2;
        }else{
            $posn = $posn + 2;
        }
        if( $posn <> 0 ){
            $n1 = InStr_php($表达式, "!",$posn);
            $n2 = InStr_php($表达式, "+",$posn);
            $n3 = InStr_php($表达式, "-",$posn);
            $n = 999999;
            if( $n1 < $n && $n1 <> 0 ){
                $符号 = "!";
                $n = $n1;
            }
            if( $n2 < $n && $n2 <> 0 ){
                $符号 = "+";
                $n = $n2;
            }
            if( $n3 < $n && $n3 <> 0 ){
                $符号 = "-";
                $n = $n3;
            }
            if($n == 999999 ){$n = 0;}
        }else{
            $n = 0;
        }
	}
	p('第一运算优先输出:'.$表达式);
    return $表达式;
    //Debug.Print$表达式

}
function 双目运算合并($表达式){
    if(IsNumeric($表达式)) return $表达式;
    /*Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim $n As Long, $n1 As Long, $n2 As Long, $pos$n As Long
    Dim result As String, str As String
    Dim $符号 As String
    Dim noact As Boolean*/
    $posn = 1;
	$result='';
	$c1='';
    $n1 = InStr_php($表达式, "+",$posn);
    $n2 = InStr_php($表达式, ".",$posn);
    $n = 999999;
    if($n1 < $n && $n1 <> 0){
        $符号 = "&";
        $n = $n1;
    }
    
    if($n2 < $n && $n2 <> 0){
        $符号 = ".";
        $n = $n2;
    }
    
    if($n == 999999){ $n = 0;}
    while($n <> 0){
        $noact = false;
        for($pos1 = $n + 1;$pos1<=strlen($表达式);$pos1++){ //'后面的
            if(Much("<>=%&.!^", Mid_php($表达式, $pos1, 1))){ $pos1 = $pos1 - 1; break;}
            if($pos1 = strlen($表达式)){break;}
		}
        for($pos2 = $n - 1;$pos2>= 1; $pos2--){ //'前面的
            if($pos2 == 1){break;}
            if(Much("<>=%&.!^", Mid_php($表达式, $pos2, 1))){
                $pos2 = $pos2 + 1;
				break;
            }
        }
        if($pos2 == 0){
        }else{
        $c1 = trim(Mid_php($表达式, $pos2, $n - $pos2));
        }
        $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n));
        if(Singles($c1, '"') || Singles($c1, "'")){
            $noact = true;
        }
        if(Singles($c2, '"') || Singles($c2, "'")){
            $noact = true;
        }
        if($符号 == "."){
            if(IsNumeric($c1) && IsNumeric($c2)){
                $noact = true;
            }
        }
        if($c1 == ""){$noact = true;}
        if(!$noact){
            if($符号=="+"){
            
                $result = 计算表达式($c1) . 计算表达式($c2);
			}elseif($符号=="."){
                if(IsNumeric($c2) && IsNumeric($c1)){
                    $noact = true;
                }else{
                    $result = 转添字符串(计算表达式($c1) . 计算表达式($c2));
                }
			}
            $str = Mid_php($表达式, $pos2, $pos1 - $pos2 + 1);
			$表达式 = str_replace($str, $result,$表达式);
            //'DoEvents
            $posn = strlen($result) + $pos2;
        }else{
            $posn = $posn + 2;
        }
        $n1 = InStr_php($表达式, "&",$posn);
        $n2 = InStr_php($表达式, ".",$posn);
        $n = 999999;
        if($n1 < $n && $n1 <> 0){
            $符号 = "+";
            $n = $n1;
        }
        
        if($n2 < $n && $n2 <> 0){
            $符号 = ".";
            $n = $n2;
        }
        
        if($n == 999999){ $n = 0;}
        
	}
    return $表达式;
    //Debug.Print$表达式
}

function 双目运算加减($表达式){
    /*Dim $pos1 As Long, $pos2 As Long
    Dim $c1 As String, $c2 As String
    Dim $n As Long, $n1 As Long, $n2 As Long, $posn As Long
    Dim $result As String, $str As String
    Dim $符号 As String
    Dim $noact As Boolean*/
	p("--------------双目运算加减输入:".$表达式);
    $posn = 1;
	$noact=false;
    $n1 = InStr_php($表达式, "+",$posn);
    $n2 = InStr_php($表达式, "-",$posn);
    $n = 999999;
    if($n1 < $n && $n1 <> 0){
        $符号 = "+";
        $n = $n1;
    }
    
    if($n2 < $n && $n2 <> 0){
        $符号 = "-";
        $n = $n2;
    }
    
    if($n == 999999){ $n = 0;}
    while($n <> 0){
		p("双目运算加减循环:".$n);
        for($pos1 = $n + 1 ; $pos1<=strlen($表达式);$pos1++){ //后面的
            if(Much("+-\%<>=!&|^", Mid_php($表达式, $pos1, 1))){ $pos1 = $pos1 - 1; break;}
            if($pos1 == strlen($表达式)){break;}
        }//Next
        for($pos2 = $n - 1;$pos2>= 1;$pos2--){ //前面的
            if($pos2 == 1){ break;}
            if(Much("+-\%<>=!&|^", Mid_php($表达式, $pos2, 1))){
                $pos2 = $pos2 + 1; break;
            }
        }//Next
        p("双目运算加减循环2:".$n);
        if($pos2 == 0){
            $c1 = 0;
        }else{
            $c1 = trim(Mid_php($表达式, $pos2, $n - $pos2));
        }
        $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n));
        //$c1 = 计算表达式($c1)
        //$c2 = 计算表达式($c2)
        if(Singles($c1, '"') || Singles($c1, "'") || $c1 == ""){
            $noact = true;
        }
        if(Singles($c2, '"') || Singles($c2, "'") || $c2 == ""){
            $noact = true;
        }
        
        if(!$noact){
            if($符号 =="+"){
				$c1 = 计算表达式($c1);
				$c2 = 计算表达式($c2);
				if(IsNumeric($c1) && IsNumeric($c2)){
					$result = Val($c1) + Val($c2);
				}else{
					$result = 转字符串($c1 . $c2);
				}
                    
			}elseif($符号 =="-"){
				$c1 = 计算表达式($c1);
				$c2 = 计算表达式($c2);
				if(IsNumeric($c1) && IsNumeric($c2)){
					//$c1 = 计算表达式($c1)
					//$c2 = 计算表达式($c2)
					$result = $c1 - $c2;
				}else{
					//$result = $c1 - $c2
					SendError("字符串怎么减你告诉我！");
					return '';
					//Exit function;
				}
            }//End Select
            if($pos2 == 0){ $pos2 = 1;}
            $str = Mid_php($表达式, $pos2, $pos1 - $pos2 + 1);
            $表达式 = str_replace($str, $result,$表达式);
            //$表达式 = Left($表达式, $n - 1) . $result . Right($表达式, strlen($表达式) - $pos1 - $pos2 - 1)
            //DoEvents
            $posn = strlen($result) + $pos2;
        }else{
            $posn = $posn + 1;
        }
        $n1 = InStr_php($表达式, "+",$posn);
        $n2 = InStr_php($表达式, "-",$posn);
        $n = 999999;
        if($n1 < $n && $n1 <> 0){
            $符号 = "+";
            $n = $n1;
		}
        
        if($n2 < $n && $n2 <> 0){
            $符号 = "-";
            $n = $n2;
		};
        
        if($n == 999999){ $n = 0;}
        
    }//Wend
	p("-----双目运算加减输出:".$表达式);
    return $表达式;
    //Debug.Print $表达式
}//End function
function 双目运算优先($表达式){
    /*Dim $pos1 As Long, $pos2 As Long
    Dim $c1 As String, $c2 As String
    Dim $n As Long, $n1 As Long, $n2 As Long, $n3 As Long, $n4 As Long, $posn As Long
    Dim $result As String, $str As String
    Dim $符号 As String
    Dim $noact As Boolean*/
    $posn = 1;
    $n1 = InStr_php($表达式, "^",$posn);

    $n = 999999;
    if($n1 < $n && $n1 <> 0){
        $符号 = "^";
        $n = $n1;
    }

    if($n == 999999){ $n = 0;}
    while($n <> 0){
        $noact = false;
        for($pos1 = $n + 1;$pos1<=strlen($表达式);$pos1++){ //后面的
            if(Much("+-*/^\!%&|><=", Mid_php($表达式, $pos1, 1))){ $pos1 = $pos1 - 1; break;}
            if($pos1 == strlen($表达式)){ break;}
        }//Next
        for($pos2 = $n - 1;$pos2>=1;$pos2--){ //前面的
            if($pos2 == 1){break;}
            if(Much("+-*/^\!%&|><=", Mid_php($表达式, $pos2, 1))){
                $pos2 = $pos2 + 1; break;
            }
        }//Next
        if($pos2 == 0){ $pos2 = 1;}
        $c1 = 计算表达式(Mid_php($表达式, $pos2, $n - $pos2));
        $c2 = 计算表达式(Mid_php($表达式, $n + 1, $pos1 - $n));
        if(Singles($c1, '"') || Singles($c1, "'") || $c1 == ""){
            $noact = true;
        }
        if(Singles($c2, '"') || Singles($c2, "'") || $c2 == ""){
            $noact = true;
        }
        if(!IsNumeric($c1) && !IsNumeric($c2)){
            SendError("双目运算需要数字！");
            $noact = true;
        }
        if(!$noact){
            if($符号 =="^"){
                $result = pow(Val($c1),Val($c2));//pow php函数
            }//End Select
            if(intval(Val($result)) <> $result){ $result = Format($result, "0.###############");}
			if(Much($result, "E+")){ $result = Format($result, "#");}
			if(Much($result, "E-")){ $result = Format($result, "0.################");}
            $str = Mid_php($表达式, $pos2, $pos1 - $pos2 + 1);
            $表达式 = str_replace($str, $result,$表达式);
            //DoEvents 
					
            $posn = strlen($result) + $pos2 - 1;
        }else{
            $posn = $posn + 1;
        }

        $n1 = InStr_php($表达式, "^",$posn);
        $n = 999999;
        if($n1 < $n && $n1 <> 0){
            $符号 = "^";
            $n = $n1;
		}
        if($n == 999999){ $n = 0;}
    }//Wend
    return $表达式;
}//End function
function 双目运算乘除($表达式){
    /*Dim $pos1 As Long, $pos2 As Long
    Dim $c1 As String, $c2 As String
    Dim $n As Long, $n1 As Long, $n2 As Long, $n3 As Long, $n4 As Long, $posn As Long
    Dim $result As String, $str As String
    Dim $符号 As String
    Dim $noact As Boolean*/
    $posn = 1;
    $n1 = InStr_php($表达式, "*",$posn);
    $n2 = InStr_php($表达式, "/",$posn);
    $n3 = InStr_php($表达式, "%",$posn);
    $n4 = InStr_php($表达式, "\\",$posn);
	
    $n = 999999;
    if($n1 < $n && $n1 <> 0){
        $符号 = "*";
        $n = $n1;
	}
    
    if($n2 < $n && $n2 <> 0){
        $符号 = "/";
        $n = $n2;
	}
    if($n3 < $n && $n3 <> 0){
        $符号 = "%";
        $n = $n3;
	}
    if($n4 < $n && $n4 <> 0){
        $符号 = "\\";
        $n = $n4;
	}
    if($n == 999999){ $n = 0;}
    while($n <> 0){
        $noact = false;
        for($pos1 = $n + 1 ;$pos1<=strlen($表达式);$pos1++){ //后面的
            if(Much("+-*/\!%&|><=", Mid_php($表达式, $pos1, 1))){ $pos1 = $pos1 - 1; break;}
            if($pos1 == strlen($表达式)){ break;}
        }//Next
        for($pos2 = $n - 1 ;$pos2 >= 1;$pos2--){ //前面的
            if($pos2 == 1){ break;}
            if(Much("+-*/\!%&|><=", Mid_php($表达式, $pos2, 1))){
                $pos2 = $pos2 + 1; break;
            }
        }//Next
        if($pos2 == 0){ $pos2 = 1;}
        $c1 = 计算表达式(Mid_php($表达式, $pos2, $n - $pos2));
        $c2 = 计算表达式(Mid_php($表达式, $n + 1, $pos1 - $n));
        if(Singles($c1, '"') || Singles($c1, "'") || $c1 == ""){
            $noact = true;
        }
        if(Singles($c2, '"') || Singles($c2, "'") || $c2 == ""){
            $noact = true;
        }
        if(!IsNumeric($c1) && !IsNumeric($c2)){
            SendError("乘除运算需要要数字！");
            $noact = true;
        }
        if(!$noact){
            if($符号 =="*"){
                $result = $c1 * $c2;
			}elseif($符号=="/"){
                if($c2 == 0){
					SendError("除数为0！");
					return '';
				}else{
					$result = $c1 / $c2;
				}
            }elseif($符号=="%"){
                $result = $c1 % $c2;
            }elseif($符号=="\\"){
                $result = intval($c1 / $c2);
            }//End Select
            if(intval(Val($result)) <> $result){ $result = Format($result, "0.###############");}
            if(Much($result, "E+")){ $result = Format($result, "#");}
            if(Much($result, "E-")){ $result = Format($result, "0.################");}
            $str = Mid_php($表达式, $pos2, $pos1 - $pos2 + 1);
            $表达式 = str_replace( $str, $result,$表达式);
            //DoEvents
            $posn = strlen($result) + $pos2 - 1;
        }else{
            $posn = $posn + 1;
        }

        $n1 = InStr_php($表达式, "*",$posn);
        $n2 = InStr_php($表达式, "/",$posn);
        $n3 = InStr_php($表达式, "%",$posn);
        $n4 = InStr_php($表达式, "\\",$posn);
        $n = 999999;
        if($n1 < $n && $n1 <> 0){
            $符号 = "*";
            $n = $n1;
		}
        
        if($n2 < $n && $n2 <> 0){
            $符号 = "/";
            $n = $n2;
		}
        
        if($n3 < $n && $n3 <> 0){
            $符号 = "%";
            $n = $n3;
		}
        
        if($n4 < $n && $n4 <> 0){
            $符号 = "\\";
            $n = $n4;
		}
        if($n == 999999){ $n = 0;}
    }//Wend
    return $表达式;
}//End function
function 双目运算逻辑($表达式){
    /*Dim $pos1 As Long, $pos2 As Long
    Dim $c1 As String, $c2 As String
    Dim $n As Long, $n1 As Long, $n2 As Long, $posn As Long
    Dim $result As String, $str As String
    Dim $符号 As String
    Dim $dengyu As Boolean*/
	p("双目运算逻辑输入：".$表达式);
    $dengyu = false;
    $posn = 1;
    $n1 = InStr_php($表达式, "&",$posn);
    $n2 = InStr_php($表达式, "|",$posn);
    $n = 999999;
    if($n1 < $n && $n1 <> 0){
        $符号 = "&";
        $n = $n1;
	}
    
    if($n2 < $n && $n2 <> 0){
        $符号 = "|";
        $n = $n2;
	}
	//p($n1.'|'.$n2);
    //die();
    if($n == 999999){ $n = 0;}
	$dengyu = false;
    while($n <> 0){
        //$n = 5
        if($符号 == "&"){
            if(Mid_php($表达式, $n + 1, 1) == "&"){$dengyu = true;}
		}elseif($符号 == '|'){
            if(Mid_php($表达式, $n + 1, 1) == "|"){$dengyu = true;}
        }
        if($dengyu){ $n = $n + 1;}
        for($pos1 = $n + 1;$pos1<=strlen($表达式);$pos1++){ //后面的
            if(Much("&|", Mid_php($表达式, $pos1, 1))){
            //if($dengyu){ break;} //$pos1 = $pos1 - 1
                $pos1 = $pos1 - 1;
                break;

            }
            if($pos1 == strlen($表达式)){break;}
        }//Next
        if($dengyu){ $n = $n - 1;}
        for($pos2 = $n - 1;$pos2>= 1;$pos2--) {//前面的
            if($pos2 == 1){break;}
            if(Much("&|", Mid_php($表达式, $pos2, 1))){
                $pos2 = $pos2 + 1; break;
            }
        }//Next
		p($pos1."|".$pos2);
		//die();
        $n = $n + 1;
        $c1 = "";
        if($pos2 <> 0){ $c1 = trim(Mid_php($表达式, $pos2, $n - $pos2 - 1));}
        if(!$dengyu){ $n = $n - 1;}
        $c2 = trim(Mid_php($表达式, $n + 1, $pos1 - $n));
        
        //if($str = "True"){ $c1 = true }else{ $c1 = false
        //$str = 计算表达式(trim(Mid_php($表达式, $n + 1, $pos1 - $n + 1)))
        //if($str = "True"){ $c2 = true }else{ $c2 = false
        p('逻辑计算：符号'.$符号.'|c1:'.$c1.'|c2:'.$c2);
		
        if($符号 =="&"){
            if($dengyu){
                $result = 'False';
                if(计算表达式($c1) == "True"){
                    if(计算表达式($c2) == "True"){
                        $result = 'True';
                    }
                }
            }else{
				//p('testokdebug');
                if(计算表达式($c1) == "True" & 计算表达式($c2) == "True"){
                    $result = 'True';
					p('$输入true');
                }else{
                    $result = 'False';
					p('&输出false');
                }
            }
		}elseif($符号 =="|"){
            if($dengyu){
                $result = false;
                if(计算表达式($c1) == "True"){
                    $result = 'True';
                }elseif(计算表达式($c2) == "True"){
                    $result = 'True';
                }
            }else{
                if(计算表达式($c1) == "True" | 计算表达式($c2) == "True"){
                    $result = 'True';
                }else{
                    $result = 'False';
                }
            }
        }//End Select
        $str = "";
        if($pos2 <> 0){ $str = Mid_php($表达式, $pos2, $pos1 - $pos2 + 1);}
        $表达式 = str_replace($str, $result,$表达式);
        //DoEvents
        $posn = strlen($result) + $pos2 - 1;
        
        $n1 = InStr_php($表达式, "&",$posn);
        $n2 = InStr_php($表达式, "|",$posn);
        $n = 999999;
        if($n1 < $n && $n1 <> 0){
            $符号 = "&";
            $n = $n1;
		}
        
        if($n2 < $n && $n2 <> 0){
            $符号 = "|";
            $n = $n2;
		}
        
        if($n == 999999){ $n = 0;}
        
    }//Wend
	p("双目运算逻辑输出：".$表达式);
    return $表达式;
    //Debug.Print $表达式
}//End function
function 双目运算赋值($表达式){
    /*Dim $pos1 As Long, $pos2 As Long
    Dim $c1 As String, $c2 As String
    Dim $n As Long, $n1 As Long, $n2 As Long, $posn As Long
    Dim $result As String, $str As String
    Dim $符号 As String
    Dim $dengyu As Boolea$n Dim $noact As Boolean*/
    $dengyu = false;
    $posn = 1;
    $n1 = InStr_php($表达式, "=",$posn);
    //$n2 = InStr_php($表达式, "|",$posn)
    $n = 999999;
    if($n1 < $n && $n1 <> 0){
        $符号 = "=";
        $n = $n1;
	}
    
    //if($n2 < $n && $n2 <> 0){
    //    $符号 = "|"
    //    $n = $n2 //}
    
    if($n == 999999){ $n = 0;}else{
		p('赋值输入：'.$表达式);
	}
    while($n <> 0){
        $noact = false;
        for($pos1 = $n + 1;$pos1<=strlen($表达式);$pos1++){ //后面的
            if(Much(";", Mid_php($表达式, $pos1, 1))){
                $pos1 = $pos1 - 1;
				break;
                
            }
            if($pos1 == strlen($表达式)){break;}
        }//Next
        for($pos2 = $n - 1;$pos2>=1;$pos2--){ //前面的
            if($pos2 == 1){break;}
            if(Much(";", Mid_php($表达式, $pos2, 1))){
                $pos2 = $pos2 + 1;
				break;
            }
        }//Next
        if($pos2 == 0){$pos2 = 1;}
        $c1 = trim(Mid_php($表达式, $pos2, $n - $pos2));
        if($c1 == ""){$noact = true;}
        if(!$noact){
            if($dengyu){$n = $n + 1;}
			//p('计算表达式(trim(Mid_php($表达式, $n + 1, $pos1 - $n)));'."|||==="."计算表达式(trim(Mid_php($表达式, $n + 1, $pos1 - $n)));"."====");
			//die('断点');
            $c2 = 计算表达式(trim(Mid_php($表达式, $n + 1, $pos1 - $n)));
			
            //if($c2 <> true && $c2 <> false){
            //if($c2 <> "" && $c2 <> "True" && $c2 <> "False"){ $c2 = 转字符串($c2)
            //}
            if($符号 == "="){
                加变量($c1, $c2, 1);
                $result = $c2;
            }//End Select
            $str = Mid_php($表达式, $pos2, $pos1 - $pos2 + 1);
            $表达式 = str_replace($str, $result,$表达式);
            //DoEvents
            $posn = strlen($result) + $pos2 - 1;
        }else{
            $posn = $posn + 1;
        }
        $n1 = InStr_php($表达式, "=",$posn);
        //$n2 = InStr_php($表达式, "|",$posn)
        $n = 999999;
        if($n1 < $n && $n1 <> 0){
            $符号 = "&";
            $n = $n1;
		}
        
        //if($n2 < $n && $n2 <> 0){
        //    $符号 = "|"
        //    $n = $n2 //}
        
        if($n == 999999){ $n = 0;}
        
    }//Wend
	p('赋值输出：'.$表达式);
    return $表达式;
    //Debug.Print $表达式
}//End function
function 双目运算判断($表达式){
    /*Dim $pos1 As Long, $pos2 As Long
    Dim $c1 As String, $c2 As String
    Dim $n As Long, $n1 As Long, $n2 As Long, $posn As Long
    Dim $result As String, $str As String
    Dim $符号 As String
    Dim $dengyu As Boolean*/
    $dengyu = false;
    $posn = 1;
    $n1 = InStr_php($表达式, ">",$posn);
    $n2 = InStr_php($表达式, "<",$posn);
    $n = 999999;
    if($n1 < $n && $n1 <> 0){
        $符号 = ">";
        $n = $n1;
	}
    
    if($n2 < $n && $n2 <> 0){
        $符号 = "<";
        $n = $n2;
	}
    
    if($n == 999999){ $n = 0;}
    while($n <> 0){
        $dengyu = false;
        if(Mid_php($表达式, $n + 1, 1) == "="){
            $dengyu = true;
        }
        for($pos1 = $n + 1;$pos1<= strlen($表达式);$pos1++){ //后面的
            //if(much("<>=&|!", Mid_php($表达式, $pos1, 1))){
            //    $pos1 = $pos1 - 1
            //    if(Mid_php($表达式, $pos1 + 1, 1) = "="){ $dengyu = true; $n = $n + 1
            //    break;}
            //}
            if($pos1 == strlen($表达式)){ break;}
        }//Next
        if($pos1 > strlen($表达式)){ $pos1 = strlen($表达式);}
        for($pos2 = $n - 1;$pos2>=1;$pos2--){ //前面的
            if($pos2 = 1){break;}
            if(Much("<>=&|!", Mid_php($表达式, $pos2, 1))){
                $pos2 = $pos2 + 1;
				break;
            }
        }//Next
        $c1 = 计算表达式(Mid_php($表达式, $pos2, $n - $pos2));
        if($dengyu){ $n = $n + 1;}
        $c2 = 计算表达式(Mid_php($表达式, $n + 1, $pos1 - $n));
        if($符号 ==">"){
            if($dengyu){
                if(Val($c1) >= Val($c2)){
					$result = 'True';
				}else{
					$result = 'False';
				}
            }else{
                if(Val($c1) > Val($c2)){
					$result = 'True';
				}else{
					$result = 'False';
				}
            }
		}elseif($符号 == "<"){
            if($dengyu){
                if(Val($c1) <= Val($c2)){
					$result = 'True';
				}else{
					$result = 'False';
				}
            }else{
                if(Val($c1) < Val($c2)){
					$result = 'True';
				}else{
					$result = 'False';
				}
            }
        }//End Select
        $str = Mid_php($表达式, $pos2, $pos1 - $pos2 + 1);
        $表达式 = str_replace($str, $result,$表达式);
        //DoEvents
        $posn = strlen($result) + $pos2 - 1;
        
        $n1 = InStr_php($表达式, ">",$posn);
        $n2 = InStr_php($表达式, "<",$posn);
        $n = 999999;
        if($n1 < $n && $n1 <> 0){
            $符号 = ">";
            $n = $n1;
		}
        
        if($n2 < $n && $n2 <> 0){
            $符号 = "<";
            $n = $n2;
		}
        
        if($n == 999999){ $n = 0;}
        
    }//Wend
    return $表达式;
    //Debug.Print $表达式
}//End function
function 双目运算等于($表达式){
	/*
    Dim $pos1 As Long, $pos2 As Long
    Dim $c1 As String, $c2 As String
    Dim $n As Long, $n1 As Long, $n2 As Long, $posn As Long
    Dim $result As String, $str As String
    Dim $符号 As String
    Dim $dengyu As Boolean*/
    $dengyu = false;
    $posn = 1;
    $n1 = InStr_php($表达式, "!",$posn);
    $n2 = InStr_php($表达式, "=",$posn);
    $n = 999999;
    if($n1 < $n && $n1 <> 0){
        $符号 = "!";
        $n = $n1;
	}
    
    if($n2 < $n && $n2 <> 0){
        $符号 = "=";
        $n = $n2;
	}
    
    if($n == 999999){ $n = 0;}
    while($n <> 0){
        $dengyu = false;
        if($符号 == "!"){
            if(Mid_php($表达式, $n + 1, 1) == "="){ $dengyu = true;}
        }elseif($符号 == "="){
            if(Mid_php($表达式, $n + 1, 1) == "="){ $dengyu = true;}
        }
        if($dengyu){ $n = $n + 1;}
        for($pos1 = $n + 1;$pos1<=strlen($表达式);$pos1++){ //后面的
            if(Much("!=&|", Mid_php($表达式, $pos1, 1))){
                $pos1 = $pos1 - 1; break;
            }
            if($pos1 = strlen($表达式)){break;}
        }//Next
        if($dengyu){
            for($pos2 = $n - 2;$pos2>=1;$pos2--){ //前面的
                if($pos2 == 1){break;}
                if(Much("!=&|", Mid_php($表达式, $pos2, 1))){
                    $pos2 = $pos2 + 1;break;
                }
            }//Next
            if($pos2 == 0){
                $c1 = "";
            }else{
                $c1 = 计算表达式(trim(Mid_php($表达式, $pos2, $n - $pos2 - 1)));
            }

            $c2 = 计算表达式(trim(Mid_php($表达式, $n + 1, $pos1 - $n)));
            if($符号 =="!"){
                if($dengyu){
                    if($c1 <> $c2){
                        $result = 'True';
                    }else{
                        $result = 'False';
                    }
                }else{
                    $result = $c2;
                    if(LCase($c2) == "true"){ $result = "False";}
                    if(LCase($c2) == "false"){ $result = "True";}
                     //优先级应该提前
                }
			}elseif($符号 == "="){
                if($dengyu){
                    if($c1 == $c2){
                        $result = 'True';
                    }else{
                        $result = 'False';
                    }
                }else{
                    加变量($c1, $c2, 0);
                    $result = $c2;
                }
            }//End Select
            if($pos2 == 0){ $pos2 = 1;}
            $str = Mid_php($表达式, $pos2, $pos1 - $pos2 + 1);
            $表达式 = str_replace($str, $result,$表达式);
            //DoEvents
            $posn = strlen($result) + $pos2;
        }else{
            $posn = $posn + 1;
        }
        $n1 = InStr_php($表达式, "!",$posn);
        $n2 = InStr_php($表达式, "=",$posn);
        $n = 999999;
        if($n1 < $n && $n1 <> 0){
            $符号 = "!";
            $n = $n1;
		}
        
        if($n2 < $n && $n2 <> 0){
            $符号 = "=";
            $n = $n2;
		}
        
        if($n == 999999){ $n = 0;}
        
    }//Wend
    return $表达式;
    //Debug.Print $表达式
}//End function 
function SendError($错误信息){
	print('<p style="color:red;">'.$错误信息.'</p>');
	return '';
}
function 分割参数($ResArray, $参数,$计算=false){
    //Dim s As String
    //ReDim ResArray(0)
    //'Exit Function
    //Dim nn As Long, n As Long, nnn As Long, num As Long
	$num=0;
	p('分割参数开始：输入的参数为：'.$参数);
    if (Much($参数, ",")) {
        $nn = 1;
        $nnn = 1;
        do{
            do{
                $n = InStr_php($参数, ",",$nn);
				p("分割参数InStr_php($参数, ',',$nn)");
                if($n <> 0){
                    $s = Mid_php($参数,$nnn, $n - $nnn);
                    //'MsgBox ResArray(1)
                    $nn = $n + 1;
					p('||||||||||||||||||nn:'.$nn);
				}else{
                    $s = Mid_php($参数, $nnn);
                    $nn = strlen($参数) + 1;
					p('break!!!!!!!!!!!');
                    break;
				}
            
			}while(Howmuch($s, "(") != Howmuch($s, ")"));
            $nnn = $nn;
            if($计算){
				$ResArray[] = 计算表达式($s);
			}else{
				$ResArray[] = $s;
			}
            $num = $num + 1;
            $n = InStr_php($参数, ",",$nn);
            //if n <> 0 Then ReDim Preserve ResArray($num)
		}while($n!=0);
        $s = Mid_php($参数, $nn);
		p(" Mid_php($参数 , $nn)=".$s);
        if ($s == ""){
            $num = $num - 1;
			p('num=num-1');
		}else{
            //ReDim Preserve ResArray(num);
            if ($计算) $ResArray[] = 计算表达式($s); else $ResArray[] = $s;
        }
        //'MsgBox ResArray(3)
	}else{
        if ($计算) $ResArray[] = 计算表达式($参数); else $ResArray[] = $参数;
	}
	return $ResArray;
}//End Function




function 转字符串($表达式){
	if (IsNumeric($表达式)){
		return $表达式;
	}else{
		return "'" . str_replace("'", "''",$表达式) . "'";
	}
}
function 转添字符串($表达式){
	global $变量数;
	$转添字符串 = '$_' . Format0($变量数, 6);
	加变量($转添字符串, 转字符串($表达式), 0);
	p("转天字符串：".$表达式."，分配：".$转添字符串);
	return $转添字符串;
}


function 简单计算($表达式){
    if (IsNumeric($表达式)) return $表达式;
    if (strlen($表达式) >= 2){
        if (Left($表达式, 1) == '"'){
            if (Right($表达式, 1) == '"'){
                //'If Not much(Mid(表达式, 2, Len(表达式) - 2), """") Then
                    
                    $简单计算 = Mid_php($表达式, 2, strlen($表达式) - 2);
                    $简单计算 = str_replace("\n", Chr(10),$简单计算);
                    $简单计算 = str_replace( "\r", Chr(13),$简单计算);
                    //'简单计算 = Replace(简单计算, "\\", "\")
                    $简单计算 = str_replace("\t", Chr(9),$简单计算);
                    $简单计算 = str_replace("\$", "$",$简单计算);
                    $简单计算 = str_replace("\'", "'",$简单计算);
                    $简单计算 = str_replace('\"', '"',$简单计算);
                    $简单计算 = str_replace("\n", Chr(13),$简单计算);
                    
                    return $简单计算;
                //'End If
			}
		}
        if (Left($表达式, 1) == "'"){
            if (Right($表达式, 1) == "'"){
                //'If Not much(Mid(表达式, 2, Len(表达式) - 2), "'") Then
                    $简单计算 = Mid_php($表达式, 2, strlen($表达式) - 2);
                    $简单计算 = str_replace("''", "'",$简单计算);
                    return $简单计算;
                //'End If
			}
		}
	}
    return $表达式;
}
function 检测变量合法性($变量名字){
	global $变量NoMoney;
	p("开始检测变量合法性！".$变量名字);
    if (!$变量NoMoney){
        //Dim 变量名 As String, 循环每个字符 As Long
        $变量名 = $变量名字;
        
        if (Left($变量名, 1) <> "$") {p("变量不合法性！无标志\$符号".$变量名字."|你的第一个字为：".Left($变量名, 1));return false;}
        $变量名 = Right($变量名, strlen($变量名) - 1);
        if (IsNumeric(Left($变量名, 1))){p("变量不合法性！数字".$变量名字);return false;}
        for($循环每个字符 = 1; $循环每个字符<=strlen($变量名);$循环每个字符++){
            if (Much("$./?<>{}|\\+-*&^%#@!~`:;\', ", Mid_php($变量名, $循环每个字符, 1))){
				p("变量不合法性！非法字符".$变量名字."第{$循环每个字符}为".Mid_php($变量名, $循环每个字符, 1));
                return false;
			}
        }
	}
	p("检测变量合法性成功合法");
    return true;
}


function 计算表达式($表达式){
	global $StopProgram;
	global $变量数;
	global $变量;
	if ($StopProgram) return '';
//If RealRun Then On Error GoTo jsbds:
    /*Dim str As String, str2 As String
    Dim n As Long, n2 As Long
    Dim p As Long
    Dim pos As Long, result As String
    Dim 最最初表达式 As String, 最初表达式 As String*/
	
    $表达式 = trim($表达式);
    $最最初表达式 = $表达式;
    if (LCase($表达式) == "true")return "True";
    if (LCase($表达式) == "false")return "False";
    if ($表达式 == "")return '';
    $表达式 = 简单计算($表达式);
    
    if (IsNumeric($表达式))  return $表达式;
    if (LCase($表达式) == "true")  return "True";
    if (LCase($表达式) == "false")  return "False";
    
    if ($最最初表达式 <> $表达式) return $表达式;
    $表达式 = 第一运算优先($表达式);
	p("从第一出来返回：".$表达式);
    $最初表达式 = $表达式;
	$表达式 = 简单计算($表达式);
	if ($最初表达式 <> $表达式) $计算表达式 = $表达式;
    if ($表达式 == "" ) return '';
    if (IsNumeric($表达式)) return $表达式;
    


    
    $表达式 = 双目运算逻辑($表达式); //'''
    if ($表达式 == "True" || $表达式 == "False") return $表达式;
    $表达式 = 单目运算优先($表达式);
	if (IsNumeric($表达式)) return $表达式;
    $表达式 = 双目运算优先($表达式);
    $表达式 = 双目运算乘除($表达式);// '''3
    $表达式 = 双目运算加减($表达式); //'''4
    if (IsNumeric($表达式)) return $表达式;
    $表达式 = 双目运算合并($表达式);// '''4
    $表达式 = 双目运算判断($表达式); //'''6
    if ($表达式 == "True" || $表达式 == "False") return $表达式;
    $表达式 = 双目运算等于($表达式);
    if ($表达式 == "True" Or $表达式 == "False") return $表达式;
    
    $表达式 = 双目运算赋值($表达式); //'''
    
    p('<hr />jisuan:'.$表达式.'End<hr />');
	
    $n = InStr_php($表达式, "$");
	//if($n!=false)print('true');else print('false'.$表达式);
    if ($n != 0){
		
		//print('<hr />jisuanok:'.$表达式.'End<hr />');
        while ($n!=0){
            //'DoEvents
            for ($pos=$n+1;$pos<=strlen($表达式);$pos++){ //'后面的
                if (Much('+-*/\()%&.^', Mid_php($表达式, $pos, 1))) {$pos = $pos - 1;break;}
                if ($pos == strlen($表达式))break;
				p('<hr />jisuanxh1:'.$表达式.'End<hr />');
            }
            $str = trim(Mid_php($表达式, $n, $pos - $n + 1));
            $n2 = strlen($str);
            $str = 读变量($str);
			p('<hr />readtext:'.$str.'End<hr />');
            if ($str == '""') $str = "";
            if ($str == "''")  $str = "";
            if (strlen($str) >= 1 ){
                if (Left($str, 1) == '"') $str = str_replace('""', '"',$str);
                if (Left($str, 1) == "'") $str = str_replace("''", "'",$str);
            }
			p('hebin:$表达式:'.$表达式.'|n:'.$n."|".Left($表达式, $n - 1)."|".$str."|".Right($表达式, strlen($表达式) - $pos));
            $表达式 = Left($表达式, $n - 1) . $str . Right($表达式, strlen($表达式) - $pos);
			p("合并f完成：".$表达式);
            //'表达式 = Mid(表达式, 1, 1)
            $p = $n + strlen($str);
            $n = InStr_php($表达式, "$",$p);
			p('jisuanxhbig:'.$表达式."InStr_php($表达式, '\$'',$p);".$表达式.'|'.$p.'/\\'.$n);
		}
	}
	p('jisuan:'.$表达式.'End');
	
    $表达式 = 简单计算($表达式);
    if($表达式 == "") return '';
    //'读变量 (Code)
    if($最初表达式 == $表达式){
    //Dim TempDimFor As Long
        for($TempDimFor = 0;$TempDimFor<=$变量数 - 1;$TempDimFor++){
            if ($变量[$TempDimFor]->name == $表达式){
                return $变量[$TempDimFor]->text;
            }
        }
    
        $表达式 = 执行函数($表达式, "");
    }
    
	
    //'MsgbBox "计算表达式出错，无法理解！": Exit Function
    //'If 最最初表达式 = 表达式 Then 表达式 = ""
    return $表达式;
    //'DoEvents
}//End Function
function 执行函数($函数名, $参数, $附加代码块=''){
	global $代码块数;
	global $代码块;
	global $变量数;
	global $变量;
	global $ExitFunction;
	global $StopProgram;
	global $ErrorIgnore;
	global $变量NoMoney;
	$执行函数='';
    //if ($RealRun) Then On Error GoTo errsh:
    if ($函数名 == "") return 计算表达式($参数);
    //Dim c() As String
    //Dim num As Long, LimiterN As Long
	p('执行函数：！！！：'.$函数名);
    $canshu=分割参数(array(), $参数);
	
    $num = count($canshu)-1;
	p('分割参数完成！数量：'.$num);
	//p('分割了的参数：');
	//print_r($canshu);
	//p('参数显示完成');
//MsgBox c(1)

    /*Dim canshun As Long
    Dim canshu As Variant
    Dim temp As String
    Dim ret As Boolean*/
	$canshun=0;
    foreach($canshu as $c){
        if ($canshu[$canshun] <> ""){
            switch($函数名){
                case "def":
				case "try":
				case "function":
				case "ch":
				case "if":
				case "iif":
				case "for":
				case "while":
				case "do":
				case "f":
				case "i":
				case "w":
				case "d":
				case "re":
				case "重复":
				case "循环":
				case "gc":
				case "switch":
				case "case":
				case "choose":
					p('跳过计算');
					break;
                default:
					p('执行函数：'.$函数名.'计算表达式：'.$canshu[$canshun].'计算结果：');
                    $canshu[$canshun] = 计算表达式(trim($canshu[$canshun]));
					p('执行函数：'.$函数名.'计算表达式：计算结果：'.$canshu[$canshun].'');
                    if ($StopProgram) return '';
            }
        }
        $canshun = $canshun + 1;
    }
    $c=$canshu;
    
    //Dim customblockn As Long
    for ($customblockn = 0;$customblockn<= $代码块数 - 1;$customblockn++){
        if($代码块[$customblockn]->names == $函数名 ){
            //Dim CanShuShuZuN As Long, CanShuShuZuN1, customblockn2 As Long
            //Dim tempcanshu As String
			$CanShuShuZuN=0;
            if (count($代码块[$customblockn]->canshu) <> 0){
                foreach ($代码块[$customblockn]->canshu as $CanShuShuZuN1){ //'代码块(customblockn).canshu
                    //Dim CanShuShuZu As String
                    $CanShuShuZu = $CanShuShuZuN1;
                    加变量($CanShuShuZu, $c[$CanShuShuZuN], 0);
                    $CanShuShuZuN = $CanShuShuZuN + 1;
				}
            
            }
            
            for($customblockn2 = 0; $customblockn2<=$代码块数 - 1;$customblockn2++){
                if ($代码块[$customblockn2]->names == $代码块[$customblockn]->code){
                    $执行函数 = 计算表达式($代码块[$customblockn2]->code);
                    $ExitFunction = false;
                    return $执行函数;
				}
            }
            $执行函数 = 计算表达式($代码块[$customblockn]->code);
            $ExitFunction = false;
            return $执行函数;
		}
	}
    /*Dim ObjTempN As Long
    For ObjTempN = 0 To 对象数 - 1
        If LCase(对象(ObjTempN).names) = 函数名 Then
            执行函数 = ExecuteAddressAPI(对象(ObjTempN).hwnd, c)
            Exit Function
        End If
    Next*/
    
    switch($函数名){
        case "=":
            $执行函数 = 计算表达式($c[0]);
			break;
		case "!":
		case "not":
            if (LCase($c[0]) == "false"){
                $执行函数 = 'True';
			}else{
                $执行函数 = 'False';
			}
			break;
		case "and":
		case "和":
            if ($c[0] && $c[1]) $执行函数 = true; else $执行函数 = false;
			break;
		case 'test':
			$执行函数=$num;
			break;
		case 'switch':
			p('进入switch');
            /*Dim switchtj As String
            Dim tempswitch As Long*/
            $switchtj = 计算表达式($c[0]);
            for($tempswitch = 0;$tempswitch<=intval($num / 2) - 1;$tempswitch++){
                if ($switchtj == 计算表达式($c[$tempswitch * 2 + 1])){
                    if ($ExitFunction){
                        $ExitFunction = false;
                        $执行函数 = 计算表达式($c[$tempswitch * 2 + 2]);
                        $ExitFunction = true;
					}else{
                        $执行函数 = 计算表达式($c[$tempswitch * 2 + 2]);
					}
                }
                if ($ExitFunction) break;
                if ($StopProgram) return 执行函数;
			}
            $ExitFunction = false;
			break;
		case 'case':
			/*Dim switchtj2 As String
            Dim tempswitch2 As Long*/
            $switchtj2 = 计算表达式($c[0]);
            for ($tempswitch2 = 0;$tempswitch2<=intval($num / 2) - 1;$tempswitch2++){
                if ($switchtj2 == 计算表达式($c[$tempswitch2 * 2 + 1])) {
                    $执行函数 = 计算表达式($c($tempswitch2 * 2 + 2));
                    return $执行函数;
				}
                if ($ExitFunction) break;
                if ($StopProgram) return $执行函数;
			}
            if ($num%2 == 1){
                $执行函数 = 计算表达式($c[$num]);
            }
            $ExitFunction = false;
			break;
		case 'choose':
			//Dim tempchoose As Long
            $tempchoose = Val(计算表达式($c[0]));
            if ($num > $tempchoose && $tempchoose >= 0){
                $执行函数 = 计算表达式(c[$tempchoose + 1]);
            }else{
                SendError("choose 所需的第一个参数必须大于等于0！");
            }
			break;
		case 'if':
			if($num==1){
				if(计算表达式($c[0] == "True")){$ret='True';}else{$ret='False';}
                if ($ret) $执行函数 = 计算表达式($c[1]);
			}elseif($num>=2){
				$ret = 计算表达式($c[0]) == "True";
                if  ($ret) $执行函数 = 计算表达式($c[1]);
                if (!$ret) $执行函数 = 计算表达式($c[2]);
			}
			break;
		case 'test2':
			$执行函数 = 'caohong';
			break;
		case "exit":
            $ExitFunction =true;
			break;
		case "end":
            $StopProgram = true;
			break;
		case "cls":
			$执行函数='False';
			break;
		case "try":
            $ErrNumber = 0;
            if (!$ErrorIgnore){
                $ErrorIgnore = true;
                $执行函数 = 计算表达式($c[0]);
                $ErrorIgnore = false;
            }else{
                $执行函数 = 计算表达式($c[0]);
            }
            $ExitFunction = false;
            if ($num >= 1 && $ErrNumber <> 0){
				
			}
            //Exit Function
			/*
tryerrs:
            If ErrNumber <> 0 Then
                加变量 c(1), ErrNumber & "," & ErrDescription, 0
                计算表达式 c(2)
            End If*/
            $ExitFunction = false;
			break;
        case "def":
		case "function":
		case "func":
            //Dim FuncCan() As String
			$FuncCan=[];
			p('!!!'.$num);
            if ($num > 1) {
                //ReDim FuncCan(num - 2) As String
                //Dim FuncN As Long
                for ($FuncN = 0 ;$FuncN<= $num - 2;$FuncN++){
                    $FuncCan[] = $c[$FuncN + 1];
				}
            }
            if ($num >= 1){
                AddCusFunc ($c[0], $c[$num], $FuncCan);
                $执行函数 = 'True';
            }else{
                $执行函数 = 'False';
            }
			break;
		case "for":
            计算表达式 ($c[0]);
            $temp = $c[1];
            if ($num < 3) return 'False';
            //Dim result As String, forcode As String
            $forcode = $c[3];
            while (计算表达式($temp) && !$ExitFunction){
                $执行函数 = 计算表达式($forcode);
                if (!$ExitFunction){
                    计算表达式 (c[2]);
                    $temp = c[1];
                }
                if ($StopProgram) return $执行函数;
			}
            $ExitFunction = false;
			break;
        case "deflim":
            if($c[0] == "True"){
                $变量NoMoney = true;
            }else{
                $变量NoMoney = false;
            }
            $执行函数 = $变量NoMoney;
			break;
		case "re":
            if (IsNumeric($c[0])){
                //Dim i As Long
                for ($i = 1;$i<=$c[0];$i++){
                    $执行函数 = 计算表达式($c[1]);
                    if ($ExitFunction)break;
                    if ($StopProgram)return $执行函数;
                }
                $ExitFunction = false;
            }else{
                $执行函数 = 'False';
            }
			break;
		//case "":
		case "while":
            $temp = $c[0];
            
            while (计算表达式($temp) == "True" && !$ExitFunction){
                $执行函数 = 计算表达式($c[1]);
                $temp = $c[0];
                if ($StopProgram) return $执行函数;
            }
            $ExitFunction = false;
			break;
		case "do":
            //Dim tempstr As String
            if ($num < 1){
                $tempstr = false;
            }else{
                $tempstr = $c[1];
            }
            do{
                $执行函数 = 计算表达式($c[0]);
                if($ExitFunction)break;
                if($StopProgram)return $执行函数;
			}while(计算表达式($tempstr) != 'True');
            $ExitFunction = false;
			break;
		case "print":
		case "msgbox":
			if ($num==0){
				print($c[0]);
				//print('print函数：'.$c[0]);
			}else{
				print('<p style="color:blue;">'.$c[0].'</p>');
			}
			break;
		case "msg":
			$执行函数=$c[0];
			print($执行函数);
			break;
		case "errcls":
            //Err.Clear
            $ErrNumber = 0;
            $ErrDescription = "";
			break;
        case "errnum":
            $执行函数 = $ErrNumber;
			break;
        case "errdes":
            $执行函数 = $ErrDescription;
			break;
		case "printl":
		case "line": 
		case "newline":
			print($c[0]."\n");
			break;
		case "lprint":
			print("\n".$c[0]);
			break;
		case "howmuch":
			$执行函数=howmuch($c[0],$c[1]);
			break;
		case "much":
			if(much($c[0],$c[1])){
				$执行函数='True';
			}else{
				$执行函数='False';
			}
			break;
		case "gc":// 'GC
            if ($c[0] == "$"){
                重置 (2);
            }elseif ($c[0] == "all"){
                重置 (1);
            }else{
                //Dim TempGCFor As Long
                for ($TempGCFor = 0 ;$TempGCFor<= $变量数 - 1;$TempGCFor++){
                    if ($变量[$TempGCFor]->name = $c[0]) {
                        $变量[$TempGCFor]->name = "";
                        $变量[$TempGCFor]->text = "";
                        return 'True';
                    }
                }
                for ($TempGCFor = 0;$TempGCFor<=代码块数 - 1;$TempGCFor++){
                    if ($代码块[$TempGCFor]->names == $c[0]){
                        $代码块[$TempGCFor]->canshu = [];
                        $代码块[$TempGCFor]->code = "";
                        $代码块[$TempGCFor]->names = "";
                        return 'True';
                    }
                }
            }
			break;
		case "true":
			return 'True';
		case "false":
			return 'False';
		case "eval"://, "计算"// '再执行字符串
            $c[0] = TrimCode($c[0]);
            if (Right($c[0], 1) <> ";") $c[0] = $c[(00)] . ";";
            $c[0] = $c[0] . "die;";
            if (!CheckCode($c[0])){
                SendError("eval计算表达式错误！");
                $执行函数 = 'False';
            }else{
                $执行函数 = 计算表达式($c[0]);
            }
			break;
		case "compile":
            SendError('no compile function for PHP');
			$执行函数='False';
			break;
		case "void"://, "空函数"
            return "";
		case "address"://, "取地址"
            return 取变量地址($c[0]);
		case "cr":
            return chr(13);
		case "lf":
            return chr(10);
		case "crlf":
            If ($c[0] <> "") SendLog("\n" . $c[0] . "\n");
            $执行函数 = "\n";
        case "error":
            if ($c[0] == "False"){
                $ErrorIgnore = True;
            }else{
                $ErrorIgnore = False;
            }
            $执行函数 = $ErrorIgnore;
			break;
		case "int"://, "quzheng", "取整", "qz"
            if ($c[0] == "" || !IsNumeric($c[0])){
                $执行函数 = 0;
            }else{
                $执行函数 = intval($c[0]);
            }
		case "val":
            $执行函数 = Val($c[0]);
		case "sleep":
            if (IsNumeric($c[0])){
                //Sleep (c(0))
                return 'True';
            }else{
                return 'False';
            }
        case "delay":
            if (IsNumeric($c[0])){
                //Sleep (c(0))
                return 'True';
            }else{
                return 'False';
            }
        case "gettickcount":
            $执行函数 = 0;//GetTickCount;
			break;
        case "timer":
            $执行函数 = 0;//Timer
			break;
        case "string":
            $执行函数 = '';//String(c(0), c(1))
			break;
        case "space":
            $执行函数 = '';//Space(Int(c(0)))
			break;
        case "inputbox"://, "输出框", "in" '从这里为VB内置函数
            /*If num = 0 Then
                执行函数 = InputBox(c(0), "", "")
            ElseIf num <= 2 Then
                执行函数 = InputBox(c(0), c(1), c(2))
            Else
                执行函数 = InputBox(c(0), c(1), c(2), c(3), c(4))
            End If*/
			break;
		case "xyz":
            return 读变量($c[0]);
		case "round":
            if ($num == 1){
                $执行函数 = Round($c[0], $c[0]);
            }else{
                $执行函数 = Round($c[0]);
            }
			break;
		case "left"://, "左"
            $执行函数 = Left($c[0], $c[0]);
			break;
		case "right"://, "右"
            $执行函数 = Right($c[0], $c[0]);
			break;
		case "mid":
            if (num == 2){
                return Mid(c(0), c(1), c(2));
            }elseif (num == 1){
                return Mid(c(0), c(1));
            }
		case "doevents":
			break;
		case "fix":
            return ;//fix($c[0);
		case "len"://, "长度", "取长度"
            return strlen($c[0]);
		case "lenfile"://, "filelen", "文件长度", "文件大小", "wjcd", "wjdx", "取文件长度"
            return 0;
		case "abs"://, "取绝对值", "绝对值"
            if (IsNumeric($c[0])){
                return abs($c[0]);
            }
		case "pi":
            return '3.14159265358979';
		case "asc":
            $执行函数 = ord($c[0]);
			break;
		case "chr":
            if (IsNumeric($c[0])) $执行函数 = chr($c[0]);
			break;
		case "replace"://, "td", "th", "替换", "替代"
            $执行函数 = str_replace(c(1), c(2),c(0));
			break;
		case "strreverse"://, "反转", "fz"
            $执行函数 = strrev($c[0]);
			break;
		case "ucase"://, "dx"
            $执行函数 = strtoupper(c(0));
			break;
		case "lcase"://, "xx"
            $执行函数 = strtolower(c(0));
			break;
		case "instr"://, "cz"
            $执行函数 = instr_php($c[1],$c[2],$c[0]);//InStr(c(0), c(1), c(2));
			break;
		case "instrrev"://, "fcz"
            $执行函数 = '';//InStrRev(c(0), c(1), c(2));
			break;
		case "now":
			$执行函数 = date('y-m-d h:i:s');//time();
			break;
		case "date":
			$执行函数 = date('y-m-d');
			break;
		case "time":
			$执行函数 = date('h:i:s');
			break;
		default:
			SendError("无此函数：" . $函数名);
            $执行函数 = "";
			//$执行函数='[测试执行函数返回结果]';
	}
	//p('执行函数'.$函数名.'|参数：'.$参数.'完成返回：'.$执行函数);
	return $执行函数;
}
function 重置($gc=''){
	global $变量;
	global $变量数;
	global $对象;
	global $对象数;
	global $代码块;
	global $代码块数;
	global $ErrorIgnore;
	global $变量NoMoney;
	global $ExitFunction;
	global $StopProgram;
	if ($gc==0){
		$变量=[];
		$变量数 = 0;
		$对象=[];
		$对象数 = 0;
		$代码块 = [];
		$代码块数 = 0;
		$ErrorIgnore = false;
		$变量NoMoney = false;
		$ExitFunction = false;
		$StopProgram = false;
	}elseif ($gc==1){
		$对象=[];
		$对象数 = 0;
		$代码块=[];
		$代码块数 = 0;
	}elseif ($gc==2){
		//Dim ClearDimFor As Long
		for ($ClearDimFor = 0;$ClearDimFor<=$变量数 - 1;$ClearDimFor++){
			if (strlen($变量[$ClearDimFor]->name) >= 2 ){
				if (left($变量[$ClearDimFor]->name, 2) <> '$_' ){
					$变量[$ClearDimFor]->name = "";
					$变量[$ClearDimFor]->text = "";
					$变量数 = $变量数 - 1;
				}
			}else{
				$变量[$ClearDimFor]->name = "";
				$变量[$ClearDimFor]->text = "";
				$变量数 = $变量数 - 1;
			}
		}
	}
}
function 结束运行(){
	global $StopProgram;
	$StopProgram = true;
}

function 转储字符串($Code){
	global $变量数;
	//global 
    //Dim posn As Long
    $posn = 1;
    /*Dim n1 As Long, n2 As Long
    Dim n3 As Long, n4 As Long
    Dim nn As Long
    Dim dimn As Long
    Dim str As String*/
	p('转储字符串开始输入：'.$Code);
	$str='';
	$n3=0;
	$n1=0;
	$n2=0;
    $dimn = $变量数;
    do{
        //'DoEvents
		//print("ceshierror:$Code, '\"',$posn");
		//print('/////'.$n1.'|||'.$n2.'\\\\\\');
		if ($posn>strlen($Code)){$n1= 0;$n2=0;}else{
			$n1 = InStr_php($Code, '"',$posn);
			$n2 = InStr_php($Code, "'",$posn);
		}
		//print('InStr_php'."$n1<>$n2");
		//print("ceshierrorend:$Code, '\"',$posn");
        if (($n1 < $n2 && $n1 <> 0) || ($n1 <> 0 && $n2 == 0)){ //'  "在前
            $nn = 1;
            do{
                do{
					//if ($n1 + $nn>strlen($Code))break;
					//p('do:'."$Code, 'yh',$n1 + $nn ");
                    $n3 = InStr_php($Code, '"',$n1 + $nn);
                    if (Mid_php($Code, $n3 + 1, 1) == '"') $nn = $n3 + 1 - $n1 + 1;
                }while(Mid_php($Code, $n3 + 1, 1) == '"');
                $n = $n3 + 1 - $n1;
                
                if ($n3 == 0 ){SendError("未结束的\"字符串"); return '';}
			}while(Mid_php($Code, $n3 - 1, 1) == "\\");
            $str = Mid_php($Code, $n1, $n3 - $n1 + 1);
			//p('woc::'.$str);
            ////'str = Replace(str, """""", """")
            加变量('$_' . Format0($dimn,6), $str, 0);
            $Code = str_replace($str, '$_' . Format0($dimn, 6),$Code);
            $dimn = $dimn + 1;
		}elseif (($n1 > $n2 && $n2 <> 0) || ($n1 == 0 && $n2 <> 0)){// 'n1>n2  '   '先出
        
            $nn = 1;
            do{
                do{
					p('small continue');
					//if ($nn + $nn>strlen($Code))break;
                    $n3 = InStr_php($Code, "'",$n2 + $nn);
					p('chtest:'.' $n3 = InStr_php($Code, "\'",$n2 + $nn);'." $n3 = InStr_php($Code, \"'\",$n2 + $nn);");
                    if ($n3 == 0) break;
                    if (Mid_php($Code, $n3 + 1, 1) == "'") $nn = $n3 + 1 - $n2 + 1;
		p('chchtest:'.'Mid_php($Code, $n3 + 1, 1)'."|"."Mid_php($Code, $n3 + 1, 1)"."=".Mid_php($Code, $n3 + 1, 1) );
					if(Mid_php($Code, $n3 + 1, 1) == "'"){
						p('success continue');
					}else{
						p('fail continue');
					}
                }while(Mid_php($Code, $n3 + 1, 1) == "'");
                $nn = $n3 + 1 - $n2;
                
                if ($n3 == 0){SendError("未结束的'字符串");return '';}
			}while(Mid_php($Code, $n3 - 1, 1) == "\\");
            $str = Mid_php($Code, $n2, $n3 - $n2 + 1);
            //'str = Replace(str, """""", """")
            加变量('$_' . Format0($dimn, 6), $str, 0);
            $Code = str_replace($str, '$_' . Format0($dimn, 6),$Code);
            $dimn = $dimn + 1;
		}elseif(IsNumeric($Code) && !Much($Code, "(") && !Much($Code, ")")){
            $str = $Code;
            加变量('$_' . Format0($dimn, 6), $str, 1);
            $Code = str_replace($str, '$_' . Format0($dimn, 6),$Code);
            $dimn = $dimn + 1;
		}
        
        $posn = $n3 - strlen($str) + 9;
		//p('关键error:'."$posn = $n3 - strlen($str) + 9;");
	}while($n1 != 0 || $n2 != 0);
	p('转储字符串结束返回：'.$Code);
    return $Code;//& Mid(Code, posn, Len(Code) - posn);
}
function IsNumeric($num){
	return is_numeric($num);
}
function lcase($cha){
	return strtolower($cha);
}
function ucase($cha){
	return strtoupper($cha);
}
function format($str,$form){
	return $str;
}

function InStr_php($ss1,$ss2,$ss3=''){
	
	//print("<br /><br />测试：$ss1,$ss2,$ss3<br /><br />");
	if ($ss3==''){
		$res= strpos($ss1,$ss2);
	}else{
		$res= strpos($ss1,$ss2,$ss3-1);
	}
	if($res===false)return 0; else return $res +1;
	
	//return strpos($ss1,$ss2);
}
function p($text){
	if (!isset($_GET['debug']))print('<hr />'.$text.'<hr />');
}
function pp($text){
	if (!isset($_GET['debug']))print('<br/>'.$text);
}
function Mid_php($ss1,$ss2,$ss3='-1'){
	if($ss3===0)return '';
	if ($ss3==='-1'){
		$res=substr($ss1,$ss2-1);
	}else{
		$res=substr($ss1,$ss2-1,$ss3);
	}
	return $res;
}
function Format0($num1,$num2){
	return sprintf("%0".$num2."d", $num1);
}
function left($s,$n){if ($n==0)return '';return substr($s,0,$n);}
function right($s,$n){if ($n==0)return '';return substr($s,-$n);}

//print(InStr_php('abcaschkabschksacde','c',2));
//print(Mid_php('abcdefg',3,2));
//print('<hr />running:');
//print(mid_php('caohong',7,0));
if(1==1){
	if (!isset($_GET['test'])){
		$mycode='true && false';
		p('测试begin');
		if(run($mycode)){
			p('success');
		};
		print('<hr /><hr /><hr /><hr /><hr /><hr /><hr /><hr />result:');
		print(GetCode());
	}else{
		if (isset($_POST['code'])){

			$_SESSION['code']=$_POST['code'];
			$mycode=$_POST['code'];
			p("您运行的代码是：".$mycode);
			if(run($mycode)){
				p('运行success！');
			};
			print('<hr /><hr /><hr /><hr /><hr /><hr /><hr /><hr />返回值:');
			print(GetCode());
			if(isset($_GET['debug'])){
				print('<hr /><a href="?test&debug">返回上一页</a>');
			}else{
				print('<hr /><a href="?test">返回上一页</a>');
			}
		}else{
			?>
	<form action="?test<?if(isset($_GET['debug']))print('&debug');?>" method="post">
		<textarea name="code" rows="50" cols="100"><?
	if(isset($_SESSION['code']))print $_SESSION['code'];
	?></textarea>
		<input type="submit" value="运行">
	</form>
			<?
		}
	}
}else{
	p(mid_php('123456',3));
}




/*
End if(}
if(if(){    ){
*/
///测试
//$res=TrimCodeBlock('func(123,{abc},345);44;{abc;sv;};');
//print($res);
