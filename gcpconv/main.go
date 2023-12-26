package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/GoogleCloudPlatform/terraform-google-conversion/v5/tfplan2cai"
	"github.com/sethvargo/go-envconfig"
	"go.uber.org/zap"
)

type convConfig struct {
	ConvertUnchanged bool   `env:"CONVERT_UNCHANGED,default=false"`
	Project          string `env:"PROJECT"`
	Region           string `env:"REGION"`
	Zone             string `env:"ZONE"`
}

func main() {
	ctx := context.Background()

	var config convConfig
	if err := envconfig.ProcessWith(ctx, &config,
		envconfig.PrefixLookuper("GCPCONV_", envconfig.OsLookuper())); err != nil {
		log.Fatal("Failed to process config: ", err)
	}

	// Read from stdin
	jsonPlan, err := io.ReadAll(os.Stdin)
	if err != nil {
		log.Fatal("Failed to read from stdin: ", err)
	}

	assets, err := tfplan2cai.Convert(ctx, jsonPlan, &tfplan2cai.Options{
		ConvertUnchanged: config.ConvertUnchanged,
		ErrorLogger:      zap.L(),
		DefaultProject:   config.Project,
		DefaultRegion:    config.Region,
		DefaultZone:      config.Zone,
		AncestryCache:    map[string]string{},
		Offline:          false,
		UserAgent:        "gcpconv-tfplan2cai",
	})
	if err != nil {
		log.Fatal("Failed to convert plan: ", err)
	}

	assetsJson, err := json.Marshal(assets)
	if err != nil {
		log.Fatal("Failed to marshal assets: ", err)
	}

	fmt.Fprintln(os.Stdout, string(assetsJson))
}
