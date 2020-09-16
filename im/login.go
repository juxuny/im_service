package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"math/rand"
	"net/http"
	"time"
)

const APP_ID = 7
const CHARSET = "abcdefghijklmnopqrstuvwxyz" + "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var seededRand *rand.Rand

func RandomStringWithCharset(length int, charset string) string {
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[seededRand.Intn(len(charset))]
	}
	return string(b)
}

func init() {
	seededRand = rand.New(rand.NewSource(time.Now().UnixNano()))
}

func login(uid int64) (string, error) {
	conn := redis_pool.Get()
	defer conn.Close()

	token := RandomStringWithCharset(24, CHARSET)

	key := fmt.Sprintf("access_token_%s", token)
	_, err := conn.Do("HMSET", key, "access_token", token, "user_id", uid, "app_id", APP_ID)
	if err != nil {
		return "", err
	}
	_, err = conn.Do("PEXPIRE", key, 1000*3600*4)
	if err != nil {
		return "", err
	}

	return token, nil
}

func respObj(w http.ResponseWriter, v interface{}, code ...int) {
	c := http.StatusOK
	if len(code) > 0 {
		c = code[0]
	}
	w.WriteHeader(c)
	w.Header().Set("Content-Type", "application/json")
	data, _ := json.Marshal(v)
	_, _ = w.Write(data)
}

func respError(w http.ResponseWriter, err error) {
	respObj(w, map[string]interface{}{
		"msg":  err.Error(),
		"code": http.StatusBadRequest,
	}, http.StatusBadRequest)
}

type loginReq struct {
	Uid int64 `json:"uid"`
}

func LoginHandler(w http.ResponseWriter, r *http.Request) {
	input, _ := ioutil.ReadAll(r.Body)
	var req loginReq
	if err := json.Unmarshal(input, &req); err != nil {
		respError(w, fmt.Errorf("invalid json"))
	}
	token, err := login(req.Uid)
	if err != nil {
		respError(w, fmt.Errorf("login failed"))
	}
	respObj(w, map[string]interface{}{
		"token": token,
	})
}
