<?php


namespace Rivestlab\CrawlerAgentBundle\Command;

use Symfony\Bundle\FrameworkBundle\Command\ContainerAwareCommand;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\EventDispatcher\Event;
use Symfony\Component\Console\Helper\ProgressHelper;
use FOS\UserBundle\Model\User;
use \Rivestlab\CrawlerAgentBundle\Crawler\Subito\Car\CarCrawlerSubito;

class ParseSubitoCarsCommand extends ContainerAwareCommand
{

    /**
     * @see Command
     */
    protected function configure()
    {
        $this
            ->setName('crawleragent:parsesubito:cars')
            ->setDescription('Crawl Subito for Cars')
            ->setDefinition(array(
                //new InputArgument('num-entries', InputArgument::OPTIONAL, 'The Num of entries to Get', 10),
                new InputOption('num-entries', null, InputOption::VALUE_OPTIONAL, 'The Num of entries to Get', 10),
                new InputOption('wipe-old-data', null, InputOption::VALUE_NONE, 'Wipe the old data before crawl')
            ))
            ->setHelp(<<<EOT
The <info>crawleragent:parsesubito:cars</info> crawls subito.it for cars:

  <info>php app/console crawleragent:parsesubito:car</info>

You can specify the number of entries to crawl:

  <info>php app/console crawleragent:parsesubito:car --num-entries=50</info>

You can specify the crawling model to use, serial or parallel. By using
    serial (default) a single http request is made, then the next entry is
    crawled. Using parallel, multiple http request are made concurrently.

  <info>php app/console crawleragent:parsesubito:car --num-entries=50</info>

You can specify the use redis parameter. In this case crawled entries are pushed
    in a redis cache server to enable lookup before persist the entry (this is
    mean to avoid duplications when the website pushed new entries and the
    alresy crawled entries are shited in futher posision

EOT
        );
    }

    /**
     * @see Command
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $cw = new CarCrawlerSubito();
        $cw->setContainer($this->getContainer());

        if ($input->hasOption('num-entries')) {
            $cw->maxEntries = $input->getOption('num-entries');
            $output->writeln("Param: " . $cw->maxEntries);
        }

        if ($input->hasOption('wipe-old-data')) {
            $wipeOldData = $input->getOption('wipe-old-data');
        }

        $progress = $this->getHelperSet()->get('progress');

        $cw->addListener(CarCrawlerSubito::ENTRY_CRAWLED, function(Event $event) use ($progress, $cw, $output) {
                if ($cw->crawledEntries == 1) {
                    $msg = "Starting to crawl. maxEntries {$cw->maxEntries}, maxPages {$cw->maxPages}";
                    $output->writeln($msg);
                    $progress->start($output, $cw->maxEntries);
                }
                $progress->advance();
            });

        $cw->addListener(CarCrawlerSubito::FINISH_EVENT, function(Event $event) use ($progress) {
                $progress->finish();
            });

        $cw->run();

        $output->writeln(sprintf(' Parsed <comment>%s</comment> entries ', $cw->crawledEntries));
    }

    /**
     * @see Command
     */
    protected function interact(InputInterface $input, OutputInterface $output)
    {
        return;
        if (!$input->getArgument('username')) {
            $username = $this->getHelper('dialog')->askAndValidate(
                $output, 'Please choose a username:', function($username) {
                    if (empty($username)) {
                        throw new \Exception('Username can not be empty');
                    }

                    return $username;
                }
            );
            $input->setArgument('username', $username);
        }

        if (!$input->getArgument('email')) {
            $email = $this->getHelper('dialog')->askAndValidate(
                $output, 'Please choose an email:', function($email) {
                    if (empty($email)) {
                        throw new \Exception('Email can not be empty');
                    }

                    return $email;
                }
            );
            $input->setArgument('email', $email);
        }

        if (!$input->getArgument('password')) {
            $password = $this->getHelper('dialog')->askAndValidate(
                $output, 'Please choose a password:', function($password) {
                    if (empty($password)) {
                        throw new \Exception('Password can not be empty');
                    }

                    return $password;
                }
            );
            $input->setArgument('password', $password);
        }
    }

}
