function path_loss_dB = path_loss(distance, alpha, PL0, d0)
    path_loss_dB = PL0 + 10*alpha*log10(distance/d0);
    