# README #

original document was written by Takashi Unuma, JMA  
last modified: 17 August 2017

DOI から文献情報を HTML 形式で出力する bash script です．


# 使い方

今のところ，以下の 3 つのみ対応しています．

## [American Meteorological Agency](http://journals.ametsoc.org) 系列の Journal
```bash
$ bash doi2ref.sh http://journals.ametsoc.org/action/showCitFormats?doi=10.1175%2F1520-0469%281963%29020%3C0130%3ADNF%3E2.0.CO%3B2
```

## [Wiley 社](http://onlinelibrary.wiley.com) 系列の Journal
```bash
$ bash doi2ref.sh http://onlinelibrary.wiley.com/enhanced/exportCitation/doi/10.1002/qj.2726
```

## [J-Stage](www.jstage.jst.go.jp) 系列の Journal
```bash
$ bash doi2ref.sh https://www.jstage.jst.go.jp/article/jmsj/95/2/95_2017-004/_article
```

# 注意
取得する URL は，編集しやすいページを直接指定しています．  
ですので，doi 情報だけ変更し，実行することをおすすめします．  
言わずもがなですが，bash が使える環境で使用して下さい．  
Windows ユーザーの皆さまは Cygwin や Bash on Windows 10 等でご使用下さい．  

# ライセンス
Copyright (c) 2017 Takashi Unuma
[Released under the MIT license](https://github.com/YukinobuKurata/YouTubeMagicBuyButton/blob/master/MIT-LICENSE.txt)
