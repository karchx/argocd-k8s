package jwt

import (
	"os"
	"time"

	jwtware "github.com/gofiber/contrib/jwt"
	"github.com/golang-jwt/jwt/v5"
)

var secretString = []byte(os.Getenv("JWT_SECRET"))
var JWTSecret = jwtware.SigningKey{Key: secretString}

type ClaimsToken struct {
	Codigo    string   `json:"codigo"`
	Nombres   string   `json:"nombres"`
	Apellidos string   `json:"apellidos"`
	Roles     []string `json:"roles"`
	Permisos  []string `json:"permisos"`
}

func GenerateJWT(id uint, user ClaimsToken) string {
	token := jwt.New(jwt.SigningMethodHS256)
	claims := token.Claims.(jwt.MapClaims)
	claims["id"] = id
	claims["exp"] = time.Now().Add(time.Hour * 72).Unix()
	claims["user"] = user
	t, _ := token.SignedString(secretString)
	return t
}
