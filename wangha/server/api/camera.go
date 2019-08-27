package api

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	vision "cloud.google.com/go/vision/apiv1"
	"github.com/pkg/errors"
	pb "google.golang.org/genproto/googleapis/cloud/vision/v1"
)

func (rt *Router) cameraHandler(w http.ResponseWriter, r *http.Request) {
	var back []byte
	var err error

	defer func() {
		_, err = w.Write(back)
		if err != nil {
			panic(err)
		}
	}()

	back = checkMethod(r.Method, "POST")
	if len(back) != 0 {
		return
	}

	var sess *session

	_, sess, back = checkSession(rt, r)
	if len(back) != 0 {
		return
	}

	if !sess.online {
		back = RetNeedPerm
		rt.infof("%s\n", back)
		return
	}

	pbe := strAnyMap{}
	body, _ := ioutil.ReadAll(r.Body)
	err = json.Unmarshal(body, &pbe)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetInvalid
		return
	}
	p := strstrmap(pbe)

	maxres := rt.cfg.default_vision_maxres
	if num, err := strconv.Atoi(p["maxres"]); err != nil {
		maxres = num
	}

	if len(p["image"]) != sha256.Size*2 {
		back = RetInvalid
		return
	}

	hashhex := p["image"]

	dir := filepath.Join(rt.cfg.image_path, string(hashhex[0]), string(hashhex[1]))

	format := "jpg"
	if len(p["format"]) != 0 {
		format = p["format"]
	}

	f, err := os.Open(filepath.Join(dir, fmt.Sprintf("%s.%s", hashhex, format)))
	if err != nil {
		back = RetNoSuchImage
		return
	}
	defer f.Close()

	image, err := vision.NewImageFromReader(f)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetNotAvailable
		return
	}

	features := []*pb.Feature{}

	for _, v := range strings.Fields(p["mode"]) {
		switch v {
		case "landmark":
			features = append(features, &pb.Feature{Type: pb.Feature_LANDMARK_DETECTION, MaxResults: int32(maxres)})
		case "label":
			features = append(features, &pb.Feature{Type: pb.Feature_LABEL_DETECTION, MaxResults: int32(maxres)})
		case "text":
			features = append(features, &pb.Feature{Type: pb.Feature_TEXT_DETECTION, MaxResults: int32(maxres)})
		case "web":
			features = append(features, &pb.Feature{Type: pb.Feature_WEB_DETECTION, MaxResults: int32(maxres)})
		case "document":
			features = append(features, &pb.Feature{Type: pb.Feature_DOCUMENT_TEXT_DETECTION, MaxResults: int32(maxres)})
		case "logo":
			features = append(features, &pb.Feature{Type: pb.Feature_LOGO_DETECTION, MaxResults: int32(maxres)})
		}
	}

	var anno *pb.AnnotateImageResponse

	anno, err = rt.vision.AnnotateImage(rt.ctx, &pb.AnnotateImageRequest{
		Image:    image,
		Features: features,
	})
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetNotAvailable
		return
	}

	back, err = json.Marshal(callback{
		Success: "200",
		Error:   "",
		Data:    *anno,
	})
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		panic(err)
	}
}
