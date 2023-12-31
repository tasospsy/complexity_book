
# -------------------------------------------------------------------------
# chapter 3 R- Figures ----------------------------------------------------
# -------------------------------------------------------------------------
source("r-figures-code/final-theme.R")

# fig 3.4 -----------------------------------------------------------------

#layout(t(1:3))
v=function(x,a) -a*x + x^3
#curve(v(x,a=-2),-3,3,bty='n')
#points(-1,-1.5,pch=16,cex=3,col =1)
#arrows(-1,-1.5,-1.5,-5,length=.1)
#curve(v(x,a=0),-3,3,bty='n')
#points(0,1.1,pch=16,cex=3,col =1)
#curve(v(x,a=2),-3,3,bty='n')
#points(.8,-.1,pch=16,cex=3,col =1)

ptmp <- function(a, point.x , point.y){
  v <- function(x,a) -a*x + x^3
  ggplot(data.frame(x = c(-3, 3)), aes(x = x)) +
    stat_function(fun = v, args = list(a = a), geom = "line", linewidth = .5) + 
    geom_point(data = data.frame(x = point.x, y = point.y), aes(x, y), shape = 16, size = 2.5, color = "black")+
    
    labs(y = expression(paste('V(X) = -', alpha, 'x + ',x^{3})),
         title = bquote(alpha == .(a)))+
    theme_minimal()+
    theme1 + theme(legend.position = 'none')
}
p1 <- ptmp(a = -2, point.x = -0.8, point.y = -.1)
p1 <- p1 + geom_segment(aes(x = -0.8, y = 0, xend = -1.8, yend = -5),
                  arrow = arrow(length = unit(0.15, "cm")))
p2 <- ptmp(a = 0, point.x = 0, point.y = 1.1)
p3 <- ptmp(a = 2, point.x = 0.8, point.y = -.2)
p <- p1 + p2 + p3
p
ggsave('media/ch3/fig-ch3-img4-old-16.jpg', width = 5, height = 3, units = 'in', dpi = 300)


# fig 3.5 -----------------------------------------------------------------
# old code
fh <- function(a) sign*sqrt(a/3)
sign <- 1;curve(fh,0,2,ylim=c(-1,1),xlim=c(-1,2),bty='n',xlab='a',ylab='X*',cex.lab=1)
sign <- -1;curve(fh,0,2,add=T,lty=3)

# new code
f <- function(a, sign) sign*sqrt(pmax(0, a/3))
p1 <- data.frame(a = seq(0, 2, by = 0.01)) %>% 
  filter(a >1) %>% 
  ggplot(aes(x = a)) +
  stat_function(fun = f, args = list(sign = 1), linewidth = .5) +
  ylim(-1, 1) +
  xlim(0, 2) +
  labs( x=expression(alpha),y='X*')+
  theme_minimal()+
  theme1 + theme(legend.position = 'none')
p1
p1 + stat_function(fun = f, args = list(sign = -1), linetype = 'dotted')
ggsave('media/ch3/fig-ch3-img5-old-17.jpg', width = 5, height = 3, units = 'in', dpi = 300)


# fig 3.17 -----------------------------------------------------------------

#layout(t(1)); par(mar=c(4,4,1,1))
x <- read.table('data/PNAS_patient_data.txt',header=T)
library(ecp) # if error: install.packages('ecp')
e1 <- e.divisive(matrix(x$dep,,1),sig=.01,min.size=10)
#plot(x$week,x$dep,type='b',pch=(e1$cluster-1)*16+1,xlab='Week',ylab='SLC-90',bty='n',main='Jump to depression')

if(length(e1$cluster) == nrow(x)){
  x <- cbind(x, 'cluster' = e1$cluster)
}
x %>% 
  ggplot(aes(x = week, y = dep, color = cluster))+
  geom_line(color = 'black', linewidth = .4) +
  geom_point(aes( fill = cluster), shape = 21, stroke = .5, color = 'black')+
  scale_fill_gradient(low = 'white', high = colors[1])+
  labs(x = 'Week', y = 'SLC-90')+
  theme_minimal()+
  theme1 + theme(legend.position = 'none')
ggsave('media/ch3/fig-ch3-img19-old-31.jpg', width = 5, height = 3, units = 'in', dpi = 300)


# fig 3.20 ----------------------------------------------------------------


x <- unlist(read.table('data/conservation_anticipation_item3.txt'))
library(mixtools) # if error: install.packages('mixtools')
result <- normalmixEM(x)
plot(result,whichplot=2,breaks=30)
p <- result$x %>% data.frame(x) %>% 
     ggplot(aes(x))+
      geom_histogram(aes(y=..density..), 
                 color = 'grey20', fill = 'grey80', linewidth = .3)+
    geom_density(color = ncolors[2], adjust = 2/3, linewidth = .3)+
  coord_flip()+
    theme1+theme_void()
p
## add custom image
library(png) 
glass_png <- readPNG('media/ch3/glasses2.png')
library(cowplot)
glasses <- ggdraw() +
  draw_image(glass_png,  x = 0, y = 0, scale = 0.9)+
  draw_text('Up/down', x = 0.61, y = 0.7, size = 35, color = "black", family = cfont)
# Plot + image
combined_plot <- plot_grid(
  glasses, p, ncol = 2, rel_widths = c(2/3, 1/3))
combined_plot

ggsave('media/ch3/fig-ch3-img20-old-32.jpg', width = 6, height = 3, units = 'in', dpi = 300)


# fig 3.23 ----------------------------------------------------------------
library(cusp)
set.seed(10)
n <- 500
X1 <- seq(-1,1,le=n) # rnorm(n) #runif(1000) # independent variable 1
a0 <- 0; a1 <- 2; b0 <- 2 # to be estimated parameters
b0s <- seq(-1,2,by=.25)
i <- 0
dat <- matrix(0,length(b0s),7)
for (b0 in b0s){
  i <- i + 1
  Y1 <- Vectorize(rcusp)(1, a1 * X1, b0)
  data <- data.frame(X1, Y1) # collect ‘measured’ variables in data
  fit <- cusp(y ~ Y1, alpha ~ X1, beta ~ 1, data)
  sf <- summary(fit)
  dat[i, ] <- c(b0, sf$r2lin.r.squared[1], sf$r2cusp.r.squared[1],sf$r2lin.bic[1], sf$r2cusp.bic[1],sf$r2lin.aic[1], sf$r2cusp.aic[1])
}
#par(mar=c(4,5,1,1))
#matplot(dat[,1],,ylab='Bic',xlab='b0',bty='n',type='b',pch=1:2,cex.lab=1.5)
#legend('right',legend=c('linear','cusp'),lty=1:2,pch=1:2,col=1:2,cex=1.5)
#abline(v=0,lty=3)
#text(-.5,800, 'no hysteresis',cex=1.5)
#text(.5,800, 'hysteresis',cex=1.5)
plotdat <- bind_cols(b = dat[,1], linear = dat[,4], cusp = dat[,5]) 
p <- plotdat %>% 
  pivot_longer(2:3,names_to = 'mod', values_to = 'bic') %>% 
  ggplot(aes(x = b, y = bic))+
  geom_line(aes(color = mod, linetype = mod))+
  geom_point(aes(color = mod, shape = mod))+
  geom_vline(xintercept = 0, linetype = 'dotted')+
  ylim(600, 1400) +
  scale_x_continuous(n.breaks = 6) +
  scale_color_manual(values = c(ncolors[1:2]))+
  labs( x=expression(beta),
        y='BIC', 
        color = '', 
        shape = '', linetype = '')+
  theme_minimal()+
  theme1 + theme()
p + annotate("text", x=-.5, y=800, label="no hysteresis",
            color="grey20", size = 7) +
  annotate("text", x=.5, y=800, label="hysteresis",
           color="grey20", size = 7) 

ggsave('media/ch3/fig-ch3-img23-old-35.jpg', width = 6, height = 3.5, units = 'in', dpi = 300)

# fig 3.24 ----------------------------------------------------------------

x <- read.table('data/stoufer.txt')
colnames(x) <- c('IntensityofFeeling','Attitude')
fit <- cusp(y ~ Attitude, alpha ~ IntensityofFeeling, beta ~ IntensityofFeeling, x)
summary(fit)
plot(fit, 'bifurcation')

#plot(fit, 'bifurcation') = plotCuspBifurcation(fit)
## plot function to work with from cusp package:
##
# > plotCuspBifurcation
# function (object, xlim = a + c(-0.3, 0.3), ylim = b + c(-0.1, 
#                                                         0.1), xlab = expression(alpha), ylab = expression(beta), 
#           hue = 0.5 + 0.25 * tanh(object$y), col = hsv(h = hue, s = 1, 
#                                                        alpha = 0.4), cex.xlab = 1.55, cex.ylab = cex.xlab, axes = TRUE, 
#           box = TRUE, add = FALSE, bifurcation.set.fill = gray(0.8), 
#           cex.scale = 15, cex = (cex.scale/log(NROW(ab))) * dens/max(dens), 
#           pch = 20) 
# {
#   obj <- object
#   ab <- obj$linear.predictors
#   a <- c(-1, 1) * max(abs(range(ab[, "alpha"])))
#   b <- c(-1, 1) * max(abs(range(ab[, "beta"])))
#   if (a[2] > b[2]) {
#     b <- a
#   }
#   else {
#     a <- b
#   }
#   if (!add) {
#     plot.new()
#     plot.window(xlim, ylim)
#     if (axes) {
#       axis(1)
#       axis(2)
#     }
#     if (box) {
#       box()
#     }
#     mtext(xlab, 1, line = 2, cex = cex.xlab)
#     mtext(ylab, 2, line = 3, cex = cex.ylab)
#     bif <- cusp.bifset(seq_range(b + c(-0.7, 0.7)))
#     polygon(c(bif[, 2], rev(bif[, 3])), c(bif[, 1], rev(bif[, 
#                                                             1])), col = bifurcation.set.fill)
#     abline(v = 0, lty = 3, col = gray(0.3))
#     abline(h = 0, lty = 3, col = gray(0.3))
#   }
#   density2D = Vectorize((function(x, y, bw = 0.9) sum(exp(-0.5 * 
#                                                             colSums((t(ab) - c(x, y))^2/bw^2)))/sqrt(2 * pi * bw^2)/NROW(ab)))
#   dens = density2D(ab[, "alpha"], ab[, "beta"])
#   points(ab[, "alpha"], ab[, "beta"], col = col, pch = 20, 
#          cex = cex)
# }

# -------------------------------------------------------------------------
x <- read.table('data/bentler.txt',header=TRUE)
#layout(t(1:8))
age <- c('age 4 to 4.5','age 4.5 to 5','age 5 to 5.5','age 5.5 to 6','age 6 to 6.5','age 6.5 to 7','age 7 to 7.5','age 7.5 to 8')
x %>% 
  tibble() %>% 
  mutate(age_range = factor(age_range, labels = age)) %>% 
  ggplot()+
  geom_bar(aes(score), fill = colors[1])+ coord_flip()+
  facet_wrap(~age_range, nrow = 1)+
  scale_x_continuous(breaks=seq(0,12,1))+
  labs(x = '', y = '')+
  theme_minimal()+
  theme1 + theme(axis.text.x = element_blank(),
                 strip.text = element_text(colour = "grey10", size = 20))
ggsave('media/ch3/fig-ch3-img25-old-37.jpg', width = 5, height = 3, units = 'in', dpi = 300)

#for(i in 1:8)
#{
#  if(i==1) {par(mar=c(4,3,2,1));names=0:12} else {names='';par(mar=c(4,1,2,1))}
#  barplot(table(factor(x[x[,1]==i,2],levels=0:12)),horiz=T,axes=F,main=age[i],xlab='',names=names,cex.main=1.5,cex.names=1.5)
#}

fit <- cusp(y ~ score, alpha ~ age_range, beta ~ age_range, x)
summary(fit)
plot(fit, 'bifurcation')


