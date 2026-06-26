+++
title = "Containers: A Means to an End, Not the End-All-Be-All"
date = 2026-06-22T00:00:00Z
draft = false
tags = ["containers", "docker", "kubernetes", "architecture", "infrastructure"]
flashNew = true   # home-list gold "New!" badge + pulse; cleared a week after publish
summary = "Containers solve a real, specific problem — and somewhere along the way we started treating them as the answer to every question. Here's the problem they actually fix, where they earn their keep, and when reaching for them is just cargo cult with a YAML accent."
[cover]
  image = "img/containers-cover.png"
  alt = "A stack of three shipping containers, the top one highlighted, wired to a single node — the one workload that earns its container."
+++

Quick question before we start: what problem does a container actually solve?

Hold that thought, because if you can't answer it cleanly, you're about to
spend a weekend writing a `Dockerfile`, a `docker-compose.yml`, a Helm chart,
and three GitHub Actions workflows to deploy a static site that an `rsync` and
a cron job would've handled in an afternoon. I've done it. You've probably done
it. Let's talk about why.

## The one problem containers were built to solve

Strip away the conference talks and the platform-team org charts, and a
container fixes exactly one thing: **"works on my machine."**

That's it. A container takes your app *and* the slice of the operating system it
depends on — the libc version, the OpenSSL build, that one font package nobody
remembers installing — and freezes them into an image. Ship the image, and the
thing that ran on your laptop runs the same way in CI, in staging, and in prod.
The environment stops being a variable. That's the whole pitch, and it's a good
one.

Everything else people love about containers — fast startup, density, clean
process isolation, immutable deploys — falls out of that same property. You
packaged the environment, so now you can stamp out a hundred identical copies
and throw them away when you're done. Powerful! But notice the shape of it:
containers are a **packaging and distribution** technology. They are a *means*.
The *end* is software that runs predictably somewhere other than your machine.

Keep that distinction in your pocket. It's the whole post.

## Where the means quietly becomes the end

Here's how the wheels come off. Containers solve the packaging problem so well
that we start reaching for them reflexively — and then for the tools that
*manage* containers, and then for the tools that manage *those*. Before long
the container isn't serving the goal; the goal is serving the container.

A few patterns I keep running into (in my own work, to be clear):

- **Kubernetes for a workload that fits on one box.** You wanted reliable
  deploys. You bought a distributed control plane, a networking model with its
  own PhD program, and an on-call rotation. The app serves 40 requests a
  minute.
- **Containerizing a build script.** It's a Bash script that runs for nine
  seconds. It does not need a base image, a registry, and a pull policy. It
  needs to be a Bash script.
- **A microservice per noun.** Twelve services, twelve images, twelve
  pipelines — to model a domain that three modules in one process described
  perfectly well last year.

None of these are *wrong* the way a bug is wrong. They're wrong the way wearing
a tuxedo to change your oil is wrong. The tool is fine. The match between the
tool and the job is the problem — and "everyone containerizes everything" is
not a match, it's a habit.

## The test I actually use

When I'm tempted to reach for a container — or worse, an orchestrator — I make
myself answer one question honestly:

> **What goes wrong if I don't?**

If the answer is a real, specific pain — "the prod box has Python 3.9 and I
need 3.12," "I need to run five copies behind a load balancer and roll them
independently," "my CI runners drift and the build is flaky" — then great, the
container is *earning* its complexity. Pay for it gladly.

If the answer is "well... nothing, but it's the standard way," stop. That's the
cargo cult talking. "Standard" is not a problem statement. Match the weight of
the solution to the weight of the problem:

| Your situation | Reach for |
|---|---|
| One app, one box, stable OS you control | A binary + systemd. Boring. Bulletproof. |
| "Works on my machine" pain across dev/CI/prod | A container. This is the home run. |
| Many identical copies, independent rollouts, autoscaling | An orchestrator — and only now |
| A nine-second shell script | A nine-second shell script |

The middle two rows are where containers shine and you should not feel clever
for using them — just correct. The trouble is almost always people living in
row one or four reaching for row three's tooling.

## A project on my bench right now

I'm building something at the moment that I can't say much about yet — it's
still under wraps. But it's a perfect illustration of both halves of this post,
so let me talk around it.

Parts of this system are a *textbook* case for containers. There are stateless
workers that need to scale out under load and scale back to nothing when it's
quiet; the runtime is fiddly enough that "here's the image" is genuinely the
sanest way to guarantee dev, CI, and prod agree; and rolling a new version
should be atomic and reversible. If you described that workload to me cold and
asked "container or no?" I wouldn't hesitate. Containers, orchestrated, the
whole nine yards. They *earn* it there.

And yet the gravitational pull on a project like this is always the same:
**containerize all the things.** Once the orchestrator is standing and the
pipeline knows how to build images, every component starts looking like a nail.
The little admin CLI. The nightly batch job. The config-templating step that
runs once at deploy. Each one *could* be a container — so the reflex says it
*should* be.

That reflex is where it stops being architecture and starts being an
antipattern. And it's not a free one. It costs you on two ledgers at once:

- **Infrastructure.** Every containerized thing wants a home: registry storage,
  a slice of a node (or a whole node it half-uses), maybe its own load balancer,
  its share of the control plane and the logging/metrics pipeline behind it. Ten
  services that each idle at 4% don't cost you 4% — they cost you ten reserved
  seats at the table. I've watched a cluster bill quietly lap the actual
  compute it was doing.
- **Manpower.** This is the one that gets underestimated. Every image is a
  standing obligation: a base image to keep patched, a CVE scan that will
  eventually go red at 4:45 on a Friday, a build to keep green, a deployment to
  keep observable. Multiply that by "all the things" and you've hired yourself a
  second job maintaining the *packaging* of work that didn't need packaging. For
  a solo developer or a small team, that tax compounds fast.

And this isn't just my anecdote. CNCF's 2025 Annual Survey clocked Kubernetes
in production at [82% of organizations surveyed][cncf-2025] — it's the default
reach now, used everywhere whether the workload asks for it or not. But CNCF's
[2023 Cloud Native FinOps microsurvey][cncf-finops] found that adopting
Kubernetes *raised* cloud spend for **49%** of respondents — against just 24%
who saved and 28% who saw no change. The leading culprits were
**overprovisioning (70%)** and **resource sprawl — things left running after
they were needed (43%)**. That's the infrastructure ledger, measured: the tool
went everywhere, and the bill followed it.

So on this project the rule I'm holding myself to is simple: the workloads that
need to scale, isolate, or reproduce get containers, gladly. The one-shot
scripts and the run-it-once glue stay exactly what they are. Same project, two
honest answers — because I'm matching the tool to each job instead of to the
platform I happened to build.

## So when *should* you containerize? (Often! Just on purpose.)

To be clear, I'm not anti-container. I recognize the utility and power of the container ecosystem... The point isn't "containers bad" — it's
"containers *for a reason*." Reach for one when:

- Your runtime environment is hard to reproduce or you don't control it.
- You need horizontal copies and clean, atomic, roll-back-able deploys.
- Your CI keeps drifting and you want the build pinned to a known image.
- You're handing the app to someone else and "here's the image" beats "here's
  a twelve-step setup doc."

And when you *do* containerize, do it leanly — a container is a packaging
decision, not an excuse to ship your whole laptop. Multi-stage builds are the
move: compile in a fat image, then copy just the artifact into a tiny one. Here's
the shape for a Go service — build stage does the work, final stage is a few
megabytes with nothing to attack:

```dockerfile
# ---- build stage: has the toolchain, never ships ----
FROM golang:1.24 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# static binary, no libc dependency to drag along
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /bin/app ./cmd/app

# ---- final stage: just the binary + certs, nothing else ----
FROM gcr.io/distroless/static:nonroot
COPY --from=build /bin/app /bin/app
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/bin/app"]
```

That image has no shell, no package manager, no OS to patch — a smaller bill and
a smaller attack surface. *This* is a container earning its keep: it solves the
"works on my machine" problem and adds almost nothing to the two ledgers we just
talked about. Compare it to a `FROM ubuntu` image with your dev environment
baked in, and you can feel the difference in both cost and care-and-feeding.

Each of those is a *problem* the container solves. That's the tell. When you
can name the problem, the container is a means to an end. When you can't, the
container has quietly become the end — and you're now maintaining infrastructure
whose only job is to justify its own existence.

Pick the tool that fits the problem in front of you, not the one that fits the
conference talk. Sometimes that's Kubernetes. Sometimes it's a single binary
and `scp`. The craft is in telling the two apart...

More to come.

---

**Sources**

- CNCF — *Kubernetes Established as the De Facto "Operating System" for AI as
  Production Use Hits 82% in 2025 CNCF Annual Cloud Native Survey* (Jan 2026).
  [cncf.io][cncf-2025]
- CNCF — *Cloud Native FinOps + Cloud Financial Management Microsurvey*
  (Dec 2023; fielded June–Nov 2023). [cncf.io][cncf-finops]

[cncf-2025]: https://www.cncf.io/announcements/2026/01/20/kubernetes-established-as-the-de-facto-operating-system-for-ai-as-production-use-hits-82-in-2025-cncf-annual-cloud-native-survey/
[cncf-finops]: https://www.cncf.io/blog/2023/12/20/cncf-cloud-native-finops-cloud-financial-management-microsurvey/
