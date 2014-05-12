<?php

namespace Rivestlab\CarBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * Brand
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class Brand
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    private $id;

    /**
     * @ORM\Column(type="string", length=100)
     */
    protected $name;

    /**
     * @var ArrayCollection 
     * 
     * @ORM\OneToMany(targetEntity="Model", mappedBy="brand")
     */
    protected $models;
    
    /**
     * Get id
     *
     * @return integer 
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set name
     *
     * @param string $name
     * @return Product
     */
    public function setName($name)
    {
        $this->name = $name;
    
        return $this;
    }

    /**
     * Get name
     *
     * @return string 
     */
    public function getName()
    {
        return $this->name;
    }
    /**
     * Constructor
     */
    public function __construct()
    {
        $this->models = new \Doctrine\Common\Collections\ArrayCollection();
    }
    
    /**
     * Add models
     *
     * @param \Rivestlab\CarBundle\Entity\Model $models
     * @return Brand
     */
    public function addModel(\Rivestlab\CarBundle\Entity\Model $models)
    {
        $this->models[] = $models;
    
        return $this;
    }

    /**
     * Remove models
     *
     * @param \Rivestlab\CarBundle\Entity\Model $models
     */
    public function removeModel(\Rivestlab\CarBundle\Entity\Model $models)
    {
        $this->models->removeElement($models);
    }

    /**
     * Get models
     *
     * @return \Doctrine\Common\Collections\Collection 
     */
    public function getModels()
    {
        return $this->models;
    }
}