package main

import (
	"io/ioutil"
	"encoding/json"
	"flag"
	"fmt"
	"image"
	"image/draw"
	"image/png"
	"log"
	"os"
	"strconv"

	"github.com/nfnt/resize"
)
var output string
var pre string
func main() {
	flag.Parse()
	var bigImgName string
	
	if len(flag.Args())!=0{
		bigImgName = flag.Arg(0);
	}
	gridWidth,err := strconv.Atoi(flag.Arg(1));
	output = flag.Arg(2);
	pre = flag.Arg(3);
	tmp,_:=strconv.ParseInt(flag.Arg(3),10,32);
	resizeNum := int(tmp);
	if(resizeNum==0){
		resizeNum = gridWidth;
	}
	if err!=nil {
		fmt.Println("请指定切块的宽度,用法案例:\nsplit.exe test.png 256 C:\\ \n")
		return
	}
	if output=="" {
		fmt.Println("没有指定输出路径,用法案例:\nsplit.exe test.png 256 C:\\ \n")
		return
	}

	file, err := os.Open(bigImgName)
	if err != nil {
		fmt.Println("os.Open(bigImgName)",err.Error())
	}

	img, err := png.Decode(file)
	if err != nil {
		log.Fatal("png.Decode(file)",err.Error())
	}
	file.Close()

	rgbimage , ok := img.(*image.NRGBA)
	if(ok){
		make_image_tiles(output + "/",gridWidth,resizeNum,rgbimage)
	}else{
		rgbimage2 := img.(*image.RGBA)
		make_image_tiles2(output + "/",gridWidth,resizeNum,rgbimage2)
	}
	
}
type MapInfo struct{
	Width int	`json:"width"`
	Height int 	`json:"height"`
	Arr	[]string `json:"arr"`
}
func make_image_tiles(path string, tile_size int, rescale_size int, rgbimage *image.NRGBA) {
	bounds := rgbimage.Bounds()
	info := &MapInfo{}
	info.Width = bounds.Max.X;
	info.Height = bounds.Max.Y;
	for cx := bounds.Min.X; cx < bounds.Max.X; cx += tile_size {
		for cy := bounds.Min.Y; cy < bounds.Max.Y; cy += tile_size {

			fname := pre + strconv.Itoa(cy/tile_size) + "_" + strconv.Itoa(cx/tile_size) + ".atf";
			info.Arr = append(info.Arr,fname)
			//分割
			//fmt.Printf("Get tile %v %v %v %v\n", cx, cy, cx+tile_size, cy+tile_size)
			//fmt.Println(pre + strconv.Itoa(cy/tile_size) + "_" + strconv.Itoa(cx/tile_size) + ".png")
			
			subimage := rgbimage.SubImage(image.Rectangle{image.Point{cx, cy}, image.Point{cx + tile_size, cy + tile_size}})
			subbounds := subimage.Bounds()
			
			x_delta := (subbounds.Max.X - subbounds.Min.X)
			y_delta := (subbounds.Max.Y - subbounds.Min.Y)
			//fmt.Println("delta: ", x_delta, " ", y_delta)
			if (x_delta < tile_size) ||
				(y_delta < tile_size) {

				newsubimage := image.NewRGBA(image.Rectangle{image.Point{0, 0}, image.Point{tile_size, tile_size}})
				draw.Draw(newsubimage, image.Rectangle{image.Point{0, 0}, image.Point{tile_size, tile_size}}, subimage, subimage.Bounds().Min, draw.Src)
				subimage = newsubimage
			}
			//fmt.Println("subdixed: ", subimage.Bounds())

			//缩小或放大
			if tile_size != rescale_size {
				subimage = resize.Resize(uint(rescale_size), uint(rescale_size), subimage, resize.Lanczos3)
			}

			//保存
			subfile, err := os.Create(path + "/"+pre + strconv.Itoa(cy/tile_size) + "_" + strconv.Itoa(cx/tile_size) + ".png")
			if err != nil {
				fmt.Println("os.Create",err.Error())
			}
			png.Encode(subfile, subimage)
			
		}
	}
	str , e := json.MarshalIndent(info,"","\t");
	fmt.Println(string(str))
	if e != nil {
		fmt.Println(e.Error())
	}
	infopath := path + "/"+pre + "mapinfo.json";
	err := ioutil.WriteFile(infopath,str,0666)
	if err != nil {
		fmt.Println(err.Error())
	}else{
		fmt.Println("切割完成")
	}
}
func make_image_tiles2(path string, tile_size int, rescale_size int, rgbimage *image.RGBA) {
	bounds := rgbimage.Bounds()
	info := &MapInfo{}
	info.Width = bounds.Max.X;
	info.Height = bounds.Max.Y;
	
	for cx := bounds.Min.X; cx < bounds.Max.X; cx += tile_size {
		for cy := bounds.Min.Y; cy < bounds.Max.Y; cy += tile_size {

			fname := pre + strconv.Itoa(cy/tile_size) + "_" + strconv.Itoa(cx/tile_size) + ".png";
			info.Arr = append(info.Arr,fname)
			
			//分割
			//fmt.Printf("Get tile %v %v %v %v\n", cx, cy, cx+tile_size, cy+tile_size)
			subimage := rgbimage.SubImage(image.Rectangle{image.Point{cx, cy}, image.Point{cx + tile_size, cy + tile_size}})
			subbounds := subimage.Bounds()
			
			x_delta := (subbounds.Max.X - subbounds.Min.X)
			y_delta := (subbounds.Max.Y - subbounds.Min.Y)
			//fmt.Println("delta: ", x_delta, " ", y_delta)
			if (x_delta < tile_size) ||
				(y_delta < tile_size) {

				newsubimage := image.NewRGBA(image.Rectangle{image.Point{0, 0}, image.Point{tile_size, tile_size}})
				draw.Draw(newsubimage, image.Rectangle{image.Point{0, 0}, image.Point{tile_size, tile_size}}, subimage, subimage.Bounds().Min, draw.Src)
				subimage = newsubimage
			}
			//fmt.Println("subdixed: ", subimage.Bounds())

			//缩小或放大
			if tile_size != rescale_size {
				subimage = resize.Resize(uint(rescale_size), uint(rescale_size), subimage, resize.Lanczos3)
			}

			//保存
			subfile, err := os.Create(path + "/"+pre + strconv.Itoa(cy/tile_size) + "_" + strconv.Itoa(cx/tile_size) + ".atf")
			if err != nil {
				fmt.Println("os.Create",err.Error())
			}
			png.Encode(subfile, subimage)
			
		}
	}
	str , e := json.MarshalIndent(info,"","\t");
	fmt.Println(string(str))
	if e != nil {
		fmt.Println(e.Error())
	}
	infopath := path + "/"+pre + "mapinfo.json";
	err := ioutil.WriteFile(infopath,str,0666)
	
	if err != nil {
		fmt.Println(err.Error())
	}else{
		fmt.Println("切割完成")
	}
}