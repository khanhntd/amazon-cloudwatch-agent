package main

import (
	"log"
	"runtime"
	"time"
)

// stressCpu runs for exactly 1 minute and stresses 1 CPU core.
func stressCpu() {
	log.Println("stressCpu()")
	i := 0
	j := 2
	start := time.Now()

	for {
		if time.Since(start) > time.Minute {
			return
		}
		i++
		j *= 2
	}

}

// stressMem runs for exactly 1 minute and allocates 200 MiB of memory.
func stressMem() {
	log.Println("stressMem")
	// Do not use make([]byte, ...) because who knows when GC will clean it up.
	data := [200 * 1024 * 1024]byte{}
	for i := 0; i < len(data); i++ {
		data[i] = 7
	}
	time.Sleep(time.Minute)
}

// Need to sync this program so that 2 instances
// running in 2 seperate containers will do the same
// workload at the same time.
// workload 1: stress 1 CPU core.
// workload 2: use 100 MiB of memory
// repeat.
func main() {
	log.Println("Hello World")
	numcpu := runtime.NumCPU()
	log.Printf("numcpu %d", numcpu)

	for {
		minute := time.Now().Minute()
		workload := minute % 2
		if workload == 0 {
			// Do workload 1
			stressCpu()
		} else {
			// Do workload 2
			stressMem()
			runtime.GC()
		}
	}
}
